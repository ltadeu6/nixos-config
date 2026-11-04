#!/usr/bin/env python3
"""nc-tarefa: tarefas enviadas pelo Nextcloud para um agente Claude.

  nc-tarefa vigiar                      laço do serviço (systemd --user nc-tarefas)
  nc-tarefa iniciar [--desde DATA]      marca o estado atual do NC como visto
                                        (com --desde, o que mudou depois de DATA
                                        fica pendente; DATA = "AAAA-MM-DD HH:MM")
  nc-tarefa estado                      pendências e tarefas
  nc-tarefa visto CAMINHO...            marca arquivos do NC escritos pelo agente
                                        como vistos (não viram tarefa nova)
  nc-tarefa entregar ARQ PASTA [NOME]   sobe ARQ para files/PASTA no NC (versão
                                        anterior vai para data/ltadeu6/arquivo-versoes)
  nc-tarefa arquivar CAMINHO            tira um arquivo de files/ para
                                        data/ltadeu6/arquivo-tarefas/<data>/
  nc-tarefa perguntar ID ARQ.txt        põe a pergunta em Claude/Perguntas no NC e
                                        espera a resposta (bloqueia; imprime a resposta)
  nc-tarefa concluir ID [resumo]        marca a tarefa como concluída e avisa

CAMINHO é relativo a files/ do usuário no NC (ex.: "OEE Dissolução/x.xlsm").

Detecção: compara (ctime, tamanho) de cada arquivo com o último estado visto.
Não usa mtime: o Nextcloud preserva o mtime do cliente, então um arquivo com data
antiga chega com mtime antigo. O ctime muda em qualquer escrita no servidor.
"""
import datetime
import fcntl
import json
import os
import re
import shlex
import subprocess
import sys
import time
import zipfile

HOST = os.environ.get("NC_TAREFA_HOST", "root@tadix.dev")
NC_DATA = "/var/lib/nextcloud/data/ltadeu6"
NC_FILES = NC_DATA + "/files"
HOME = os.path.expanduser("~")
STATE_DIR = os.path.join(os.environ.get("XDG_STATE_HOME", HOME + "/.local/state"), "nc-tarefas")
STATE = os.path.join(STATE_DIR, "estado.json")
TASKS = os.environ.get("NC_TAREFA_DIR", HOME + "/Tarefas/NC")
INSTRUCOES = os.environ.get("NC_TAREFA_INSTRUCOES", os.path.join(os.path.dirname(os.path.abspath(__file__)), "instrucoes-agente.md"))
POLL = int(os.environ.get("NC_TAREFA_POLL", "60"))
PERGUNTAS = "Claude/Perguntas"
SSH_OPTS = ["-o", "BatchMode=yes", "-o", "ConnectTimeout=20", "-o", "ServerAliveInterval=15"]


def log(*a):
    print(datetime.datetime.now().strftime("%F %T"), *a, flush=True)


def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def ssh(cmd, **kw):
    return subprocess.run(["ssh", *SSH_OPTS, HOST, "bash -c " + shlex.quote(cmd)], **kw)


def notify(title, body=""):
    subprocess.run(["notify-send", "-a", "nc-tarefa", title, body], capture_output=True)


# ---------- estado (com trava, o serviço e os comandos do agente escrevem nele)

class Estado:
    def __enter__(self):
        os.makedirs(STATE_DIR, exist_ok=True)
        self.lock = open(STATE + ".lock", "w")
        fcntl.flock(self.lock, fcntl.LOCK_EX)
        try:
            with open(STATE) as f:
                self.d = json.load(f)
        except FileNotFoundError:
            self.d = None
        return self

    def __exit__(self, *exc):
        if self.d is not None and exc[0] is None:
            tmp = STATE + ".tmp"
            with open(tmp, "w") as f:
                json.dump(self.d, f, ensure_ascii=False, indent=1)
            os.replace(tmp, STATE)
        fcntl.flock(self.lock, fcntl.LOCK_UN)
        self.lock.close()


def listar(caminhos=None):
    """{caminho: [ctime, tamanho, mtime]} dos arquivos em files/ (ou só dos caminhos dados)."""
    if caminhos:
        alvo = " ".join(shlex.quote(NC_FILES + "/" + c) for c in caminhos)
        # %P fica vazio quando o próprio arquivo é o ponto de partida: usa %p e corta o prefixo
        cmd = f"find {alvo} -type f -printf '%C@\\t%s\\t%T@\\t%p\\0' 2>/dev/null; true"
    else:
        cmd = f"find {NC_FILES} -type f -printf '%C@\\t%s\\t%T@\\t%P\\0'"
    r = ssh(cmd, capture_output=True, timeout=120)
    if r.returncode != 0:
        raise RuntimeError("listagem falhou: " + r.stderr.decode(errors="replace")[-300:])
    out = {}
    for item in r.stdout.decode("utf-8", errors="surrogateescape").split("\0"):
        if not item:
            continue
        ct, sz, mt, p = item.split("\t", 3)
        if p.startswith(NC_FILES + "/"):
            p = p[len(NC_FILES) + 1:]
        out[p] = [round(float(ct), 3), int(sz), round(float(mt))]
    return out


def chave(v):
    return [v[0], v[1]]


def ignorado(p):
    base = os.path.basename(p)
    return (p.startswith("Claude/") or ".ocTransferId" in p or base.endswith(".part")
            or base.startswith(".~lock.") or base.startswith("~$") or base == ".DS_Store")


def marcar_vistos(caminhos):
    snap = listar(caminhos)
    with Estado() as e:
        if e.d is None:
            die("estado não iniciado (nc-tarefa iniciar)")
        for c in caminhos:
            if c in snap:
                e.d["vistos"][c] = chave(snap[c])
            else:
                e.d["vistos"].pop(c, None)
            e.d["pendentes"].pop(c, None)
    return snap


# ---------- tarefas

def slug(s):
    s = re.sub(r"[^\w.-]+", "-", s, flags=re.UNICODE).strip("-")
    return s[:40] or "tarefa"


def nome_zip(info):
    n = info.filename
    if not info.flag_bits & 0x800:
        try:
            n = n.encode("cp437").decode("cp850")
        except (UnicodeEncodeError, UnicodeDecodeError):
            pass
    return n


def manifesto(tdir, arquivos):
    linhas = []
    for c, v in arquivos.items():
        local = os.path.join(tdir, "entrada", c)
        mt = datetime.datetime.fromtimestamp(v[2]).strftime("%F %T")
        ct = datetime.datetime.fromtimestamp(v[0]).strftime("%F %T")
        linhas.append(f"## {c}\n- no NC: {NC_FILES}/{c}\n- cópia local: {local}\n"
                      f"- tamanho: {v[1]} bytes; chegou ao servidor em {ct} (mtime {mt}, pode ser antigo)\n")
        if zipfile.is_zipfile(local):
            with zipfile.ZipFile(local) as z:
                linhas.append("- conteúdo do zip:")
                for i in z.infolist():
                    linhas.append(f"    {i.file_size:>10}  {nome_zip(i)}")
                for i in z.infolist():
                    if nome_zip(i).lower().endswith((".txt", ".md")) and i.file_size < 20000:
                        txt = z.read(i).decode("utf-8", errors="replace")
                        linhas.append(f"\n### texto de {nome_zip(i)}\n```\n{txt}\n```")
        elif c.lower().endswith((".txt", ".md")) and v[1] < 20000:
            with open(local, encoding="utf-8", errors="replace") as f:
                linhas.append(f"\n### texto\n```\n{f.read()}\n```")
        linhas.append("")
    return "\n".join(linhas)


def triar(tdir, man):
    prompt = f"""Você faz a triagem de arquivos que o usuário (Lucas) acabou de subir no Nextcloud dele.
Ele usa o Nextcloud para mandar tarefas para um agente Claude (em geral um zip com um TODO.txt ou
README com instruções e os arquivos de trabalho, mas pode ser qualquer arquivo com instruções).
Também pode ser só um arquivo sincronizado/atualizado que não pede nada (ex.: ele salvou uma
planilha numa das pastas de trabalho). Os arquivos estão em ./entrada; o manifesto está abaixo.
Se precisar, leia os arquivos. Não execute nada, não altere nada.

Decida:
- "tarefa": há um pedido de trabalho claro para o agente;
- "duvida": parece um pedido, mas não dá para saber o que fazer;
- "nao": não é pedido (atualização de arquivo, backup, etc.).

Responda na ÚLTIMA linha só com JSON:
{{"decisao": "tarefa|duvida|nao", "titulo": "título curto em pt-BR", "motivo": "uma frase"}}

MANIFESTO
{man}"""
    try:
        r = subprocess.run(["claude", "-p", "--model", "sonnet", "--tools", "Read,Glob,Grep",
                            "--permission-mode", "bypassPermissions", prompt],
                           cwd=tdir, capture_output=True, text=True, timeout=900)
        for linha in reversed(r.stdout.strip().splitlines()):
            linha = linha.strip().strip("`")
            if linha.startswith("{"):
                d = json.loads(linha)
                if d.get("decisao") in ("tarefa", "duvida", "nao"):
                    return d
        log("triagem sem JSON:", r.stdout[-500:], r.stderr[-500:])
    except Exception as ex:  # noqa: BLE001
        log("triagem falhou:", ex)
    return {"decisao": "duvida", "titulo": "arquivos novos no Nextcloud", "motivo": "triagem automática falhou"}


def nova_tarefa(arquivos):
    agora = datetime.datetime.now()
    principal = sorted(arquivos)[0]
    tid = agora.strftime("%Y-%m-%d_%H%M") + "-" + slug(os.path.splitext(os.path.basename(principal))[0])
    tdir = os.path.join(TASKS, tid)
    os.makedirs(os.path.join(tdir, "entrada"), exist_ok=True)
    for c in arquivos:
        local = os.path.join(tdir, "entrada", c)
        os.makedirs(os.path.dirname(local), exist_ok=True)
        with open(local, "wb") as f:
            subprocess.run(["ssh", *SSH_OPTS, HOST, "cat " + shlex.quote(NC_FILES + "/" + c)],
                           stdout=f, check=True, timeout=1800)
    man = manifesto(tdir, arquivos)
    with open(os.path.join(tdir, "MANIFESTO.md"), "w") as f:
        f.write(man)
    tri = triar(tdir, man)
    meta = {"id": tid, "dir": tdir, "arquivos": arquivos, "triagem": tri,
            "status": "ignorada" if tri["decisao"] == "nao" else "lancar", "criada": agora.isoformat()}
    with open(os.path.join(tdir, "tarefa.json"), "w") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    log("tarefa", tid, tri)
    if tri["decisao"] == "nao":
        notify("Nextcloud: arquivo novo (não é tarefa)", f"{', '.join(arquivos)}\n{tri.get('motivo', '')}")
        return
    escrever_tarefa(meta, man)
    lancar(meta)


def escrever_tarefa(meta, man):
    tdir, tid, tri = meta["dir"], meta["id"], meta["triagem"]
    with open(INSTRUCOES) as f:
        instr = f.read()
    instr = (instr.replace("@ID@", tid).replace("@DIR@", tdir)
             .replace("@DECISAO@", tri["decisao"]).replace("@MOTIVO@", tri.get("motivo", "")))
    with open(os.path.join(tdir, ".instrucoes-agente.md"), "w") as f:
        f.write(instr)
    with open(os.path.join(tdir, "TAREFA.md"), "w") as f:
        f.write(f"# {tri.get('titulo', tid)}\n\nID da tarefa: `{tid}`\n"
                f"Triagem automática: **{tri['decisao']}** ({tri.get('motivo', '')})\n\n"
                f"Arquivos que chegaram no Nextcloud (cópias em ./entrada):\n\n{man}\n")
    run = os.path.join(tdir, "run.sh")
    titulo = ("NC: " + tri.get("titulo", tid))[:60]
    with open(run, "w") as f:
        f.write(f"""#!/usr/bin/env bash
cd {shlex.quote(tdir)}
claude --dangerously-skip-permissions --name {shlex.quote(titulo)} \\
  --remote-control={shlex.quote(titulo)} \\
  --append-system-prompt-file {shlex.quote(tdir + '/.instrucoes-agente.md')} \\
  "Chegou uma tarefa pelo Nextcloud. Leia TAREFA.md e cumpra seguindo as instruções de sistema."
echo; echo "Sessão do agente encerrada. Retomar: cd {shlex.quote(tdir)} && claude --continue"
exec "${{SHELL:-bash}}"
""")
    os.chmod(run, 0o755)


def lancar(meta):
    tdir = meta["dir"]
    titulo = ("NC: " + meta["triagem"].get("titulo", meta["id"]))[:60]
    cmd = f"[workspace 9 silent] kitty --class nc-tarefa --title {shlex.quote(titulo)} {shlex.quote(tdir + '/run.sh')}"
    r = subprocess.run(["hyprctl", "-i", "0", "dispatch", "exec", cmd], capture_output=True, text=True)
    ok = r.returncode == 0 and "ok" in r.stdout
    meta["status"] = "em-andamento" if ok else "lancar"
    with open(os.path.join(tdir, "tarefa.json"), "w") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    if ok:
        log("agente lançado", meta["id"])
        notify("Nextcloud: tarefa recebida", f"{meta['triagem'].get('titulo', '')}\nAgente aberto no workspace 9 (Remote Control ligado)")
    else:
        log("sem Hyprland, tentando depois:", r.stdout, r.stderr)


def relancar_pendentes():
    if not os.path.isdir(TASKS):
        return
    for t in os.listdir(TASKS):
        p = os.path.join(TASKS, t, "tarefa.json")
        try:
            with open(p) as f:
                meta = json.load(f)
        except (OSError, ValueError):
            continue
        if meta.get("status") == "lancar":
            lancar(meta)


# ---------- comandos

def cmd_iniciar(a):
    desde = None
    if a[:1] == ["--desde"]:
        desde = datetime.datetime.strptime(a[1], "%Y-%m-%d %H:%M").timestamp()
    snap = listar()
    with Estado() as e:
        e.d = {"vistos": {p: chave(v) for p, v in snap.items() if desde is None or v[0] < desde},
               "pendentes": {}}
        n = len(snap) - len(e.d["vistos"])
    print(f"{len(snap)} arquivos; {n} ficam para o vigia tratar")


def cmd_vigiar(a):
    log("vigiando", HOST, NC_FILES, f"a cada {POLL}s")
    while True:
        try:
            ciclo()
        except Exception as ex:  # noqa: BLE001
            log("erro:", ex)
        time.sleep(POLL)


def ciclo():
    relancar_pendentes()
    snap = listar()
    with Estado() as e:
        if e.d is None:
            e.d = {"vistos": {p: chave(v) for p, v in snap.items()}, "pendentes": {}}
            log("estado iniciado com", len(snap), "arquivos")
            return
        vistos, pend = e.d["vistos"], e.d["pendentes"]
        for p in list(vistos):
            if p not in snap:
                del vistos[p]
        mudou = {p: v for p, v in snap.items() if vistos.get(p) != chave(v) and not ignorado(p)}
        # pronto quando nada mudou desde o ciclo anterior (upload terminou)
        estavel = bool(mudou) and set(mudou) == set(pend) and all(chave(mudou[p]) == pend[p] for p in mudou)
        if not estavel:
            e.d["pendentes"] = {p: chave(v) for p, v in mudou.items()}
            if mudou:
                log("mudanças, aguardando estabilizar:", list(mudou))
            return
        for p, v in mudou.items():
            vistos[p] = chave(v)
        e.d["pendentes"] = {}
    nova_tarefa(mudou)


def cmd_estado(a):
    with Estado() as e:
        if e.d:
            print("pendentes:", json.dumps(e.d["pendentes"], ensure_ascii=False))
            print("vistos:", len(e.d["vistos"]))
    if os.path.isdir(TASKS):
        for t in sorted(os.listdir(TASKS)):
            try:
                with open(os.path.join(TASKS, t, "tarefa.json")) as f:
                    m = json.load(f)
                print(f"{m['status']:13} {t}  {m['triagem'].get('titulo', '')}")
            except (OSError, ValueError):
                pass


def cmd_visto(a):
    if not a:
        die("uso: nc-tarefa visto CAMINHO...")
    for c, v in marcar_vistos([c.strip("/") for c in a]).items():
        print("visto:", c)


def cmd_entregar(a):
    if len(a) < 2:
        die("uso: nc-tarefa entregar ARQ PASTA_NC [NOME]")
    arq, pasta = a[0], a[1].strip("/")
    nome = a[2] if len(a) > 2 else os.path.basename(arq)
    if not os.path.isfile(arq):
        die("arquivo não encontrado: " + arq)
    rel = (pasta + "/" + nome).strip("/")
    dest = NC_FILES + "/" + rel
    arqv = f"{NC_DATA}/arquivo-versoes/{datetime.date.today().isoformat()}/{pasta}".rstrip("/")
    hora = datetime.datetime.now().strftime("%H%M")
    ssh(f"mkdir -p {shlex.quote(os.path.dirname(dest))} && if [ -e {shlex.quote(dest)} ]; then mkdir -p {shlex.quote(arqv)} && "
        f"mv {shlex.quote(dest)} {shlex.quote(arqv + '/' + hora + ' ' + nome)} && echo 'versão anterior -> {arqv}'; fi", check=True)
    with open(arq, "rb") as f:
        subprocess.run(["ssh", *SSH_OPTS, HOST, "cat > " + shlex.quote(dest)], stdin=f, check=True)
    scan(os.path.dirname(rel))
    marcar_vistos([rel])
    print("entregue:", rel)


def scan(rel_dir):
    alvo = ("ltadeu6/files/" + rel_dir).rstrip("/")
    ssh(f"chown -R nextcloud:nextcloud {shlex.quote(NC_DATA)}/files {shlex.quote(NC_DATA)}/arquivo-* 2>/dev/null; "
        f"nextcloud-occ files:scan --path={shlex.quote(alvo)} >/dev/null 2>&1", check=False)


def cmd_arquivar(a):
    if not a:
        die("uso: nc-tarefa arquivar CAMINHO")
    rel = a[0].strip("/")
    dest = f"{NC_DATA}/arquivo-tarefas/{datetime.date.today().isoformat()}"
    ssh(f"mkdir -p {shlex.quote(dest)} && mv {shlex.quote(NC_FILES + '/' + rel)} {shlex.quote(dest + '/')}", check=True)
    scan(os.path.dirname(rel))
    with Estado() as e:
        e.d["vistos"].pop(rel, None)
    print(f"arquivado em {dest}/{os.path.basename(rel)}")


def cmd_perguntar(a):
    if len(a) < 2:
        die("uso: nc-tarefa perguntar ID ARQ.txt")
    tid, arq = a[0], a[1]
    with open(arq, encoding="utf-8") as f:
        texto = f.read().rstrip()
    rel = f"{PERGUNTAS}/{tid} - pergunta.txt"
    corpo = (f"{texto}\n\n"
             "------------------------------------------------------------\n"
             "Para responder: escreva abaixo da linha RESPOSTA e salve este arquivo\n"
             f"(ou suba um arquivo \"{tid} - resposta.txt\" nesta pasta).\n"
             "RESPOSTA:\n\n")
    ssh(f"mkdir -p {shlex.quote(NC_FILES + '/' + PERGUNTAS)} && cat > {shlex.quote(NC_FILES + '/' + rel)}",
        input=corpo.encode(), check=True)
    scan(PERGUNTAS)
    base = listar([rel])[rel]
    notify("Agente perguntou no Nextcloud", f"{rel}")
    print(f"pergunta em {rel}; aguardando resposta...", flush=True)
    ultimo, quieto = None, 0
    resp = f"{PERGUNTAS}/{tid} - resposta"
    while True:
        time.sleep(60)
        try:
            snap = {p: v for p, v in listar().items() if p.startswith(PERGUNTAS + "/")}
        except Exception:  # noqa: BLE001
            continue
        alvo = {p: v for p, v in snap.items() if p.startswith(resp) or (p == rel and chave(v) != chave(base))}
        if not alvo:
            continue
        estado = sorted((p, chave(v)) for p, v in alvo.items())
        quieto = quieto + 1 if estado == ultimo else 0
        ultimo = estado
        if quieto >= 2:  # sem mudança por ~2 min: terminou de escrever
            break
    for p, _ in ultimo:
        r = ssh("cat " + shlex.quote(NC_FILES + "/" + p), capture_output=True)
        print(f"===== {p}\n" + r.stdout.decode(errors="replace"))


def cmd_concluir(a):
    if not a:
        die("uso: nc-tarefa concluir ID [resumo]")
    p = os.path.join(TASKS, a[0], "tarefa.json")
    with open(p) as f:
        m = json.load(f)
    m["status"] = "concluida"
    m["resumo"] = " ".join(a[1:])
    with open(p, "w") as f:
        json.dump(m, f, ensure_ascii=False, indent=1)
    notify("Tarefa do Nextcloud concluída", m["resumo"] or a[0])
    print("concluída:", a[0])


def main(a):
    if not a or a[0] in ("-h", "--help", "help"):
        print(__doc__)
        return
    c = {"vigiar": cmd_vigiar, "iniciar": cmd_iniciar, "estado": cmd_estado, "visto": cmd_visto,
         "entregar": cmd_entregar, "arquivar": cmd_arquivar, "perguntar": cmd_perguntar,
         "concluir": cmd_concluir}.get(a[0])
    if not c:
        die("comando desconhecido: " + a[0])
    c(a[1:])


if __name__ == "__main__":
    main(sys.argv[1:])
