# /orient — Guia operacional do nixos-config

Você está trabalhando no repositório NixOS pessoal de `ltadeu6`. Este guia cobre tudo o que você precisa para operar, modificar e depurar este sistema. **Leia com atenção antes de fazer qualquer mudança.**

---

## 1. Fonte de verdade primária

O arquivo **`AGENTS.md`** na raiz do repo é a documentação canônica e deve ser consultado sempre. Este skill é um complemento de orientação rápida — se houver conflito, o `AGENTS.md` prevalece.

Se tiver dúvidas adicionais que não estejam aqui nem no `AGENTS.md`, **inspecione o código diretamente**:
- `hosts/Nixos/configuration.nix` — sistema local
- `hosts/NixOracle/configuration.nix` — VPS Oracle
- `home/ltadeu6.nix` — Home Manager
- `flake.nix` — entrypoint, inputs, overlays
- `secrets/secrets.nix` — mapa de todos os secrets

Use `rg -n 'termo'` para buscar definições. Leia os arquivos antes de assumir qualquer coisa.

---

## 2. Dois sistemas neste flake

| Sistema | Host | Onde fica | Como fazer deploy |
|---------|------|-----------|-------------------|
| `Nixos` | máquina local x86_64 | `hosts/Nixos/` | `sudo nixos-rebuild switch --flake .#Nixos` |
| `NixOracle` | VPS Oracle Cloud (`tadix.dev`) | `hosts/NixOracle/` | `./deploy-oracle.sh` |

**Nunca confunda os dois.** Secrets, serviços e hardware são completamente diferentes.

---

## 3. Deploy do NixOracle (VPS)

Sempre use o script de deploy — ele cria uma snapshot antes de cada rebuild:

```bash
./deploy-oracle.sh
```

O script:
1. Lê credenciais OCI de `~/.oci/` (gerado automaticamente pelo Home Manager)
2. Localiza a instância e o boot volume via API
3. Apaga snapshots antigas se houver mais de 4
4. Cria nova snapshot incremental
5. Roda `nixos-rebuild switch --flake .#NixOracle --target-host root@tadix.dev`

Se `~/.oci/` não existir, rode um `sudo nixos-rebuild switch --flake .#Nixos` para ativar o `home.activation.ociCredentials`.

---

## 4. Secrets e credenciais

### Como funciona

- Secrets ficam em `secrets/*.age`, criptografados com `age` usando a chave SSH do usuário.
- O `agenix` descriptografa em `/run/agenix/<nome>` na ativação do sistema.
- A identidade usada é `~/.ssh/id_ed25519`.
- Para adicionar um secret: criptografe com `age`, adicione em `secrets/secrets.nix`, declare em `age.secrets` no `configuration.nix`.

### Secrets disponíveis hoje

| Arquivo `.age` | Onde é usado |
|---------------|--------------|
| `openai_api_key` | `OPENAI_API_KEY` no ambiente (fish + profile.d) |
| `openclaw_gateway_token` | `OPENCLAW_GATEWAY_TOKEN` + `~/.config/openclaw/gateway.env` |
| `forgejo_api_token` | `FORGEJO_API_TOKEN` no ambiente |
| `android_release_keystore` | keystore para assinar APKs |
| `android_release_store_password` | senha do keystore |
| `android_release_key_password` | senha da chave dentro do keystore |
| `matrix_android_firebase_service_account` | `.secrets/firebase-service-account.json` no projeto |
| `matrix_android_google_services` | `app/google-services.json` no projeto |
| `matrix_android_commander_credentials` | `.mc/credentials.json` no projeto |
| `cloudflare_worker_api_token` | deploy de Workers |
| `cloudflare_dns_api_token` | leitura de DNS/Zone |
| `minecraft_rcon_password` | servidor Minecraft |
| `oci_key` | chave privada OCI API → `~/.oci/key.pem` |
| `oci_config` | config OCI → `~/.oci/config` |

### Nunca imprima conteúdo de `/run/agenix/*` ou arquivos `.age`.

---

## 5. Como buildar um APK Android

O projeto Android relevante é o `matrix-android`. O processo exige três coisas:

### 5a. Credenciais de assinatura

```bash
# Exporta variáveis de ambiente para o processo filho apenas
android-signing-env ./gradlew assembleRelease
# ou
android-signing-env ./gradlew bundleRelease
```

O helper `android-signing-env` expõe:
- `ANDROID_KEYSTORE_PATH` → `/run/agenix/android_release_keystore`
- `ANDROID_KEYSTORE_TYPE`, `ANDROID_KEY_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`
- `PUSH_GATEWAY_URL` → `https://matrix-push-gateway.ltadeu6.workers.dev`

### 5b. Secrets do projeto (Firebase, google-services, credenciais)

```bash
# No diretório raiz do projeto matrix-android:
matrix-android-secrets .
```

Isso cria symlinks de `/run/agenix/` para os paths esperados pelo projeto.

### 5c. Se faltar alguma ferramenta (Gradle, JDK, etc.)

Use `nix develop` — veja a seção 8.

---

## 6. OCI CLI (Oracle Cloud)

Para operações na Oracle Cloud:

```bash
nix-shell -p oci-cli --run "oci <comando> --auth api_key"
```

As credenciais ficam em `~/.oci/config` e `~/.oci/key.pem` (symlinks para `/run/agenix/`). Se não existirem, recrie com:

```bash
sudo nixos-rebuild switch --flake .#Nixos
```

Operações comuns:
```bash
# Listar instâncias
nix-shell -p oci-cli --run "oci compute instance list --compartment-id $(awk -F= '/^tenancy/{gsub(/ /,"",$2);print $2}' ~/.oci/config) --auth api_key"

# Criar snapshot manual
nix-shell -p oci-cli --run "oci bv boot-volume-backup create --boot-volume-id <id> --display-name 'manual-backup' --type INCREMENTAL --auth api_key"
```

Limite free tier: **5 snapshots**. Apague antigas antes de criar novas.

---

## 7. Serviços no NixOracle (VPS)

| Serviço | URL | Porta interna |
|---------|-----|---------------|
| homepage | `tadix.dev` | — |
| Forgejo | `git.tadix.dev` | 3000 |
| Nextcloud 32 | `nextcloud.tadix.dev` | — |
| JupyterLab | `jupyter.tadix.dev` | 8888 |
| BioLab (site estático) | `biolab.tadix.dev` | — |

- SSH: `root@tadix.dev` ou via Tailscale `root@100.64.0.1`
- IP público: `204.216.130.111`
- Deploy: **sempre via `./deploy-oracle.sh`**

---

## 8. Software ausente — use `nix develop` ou `nix-shell`

Se qualquer ferramenta não estiver disponível no ambiente atual, **não tente instalar globalmente**. Use:

```bash
# Ambiente temporário com um pacote
nix-shell -p <pacote> --run "<comando>"

# Ex: OCI CLI
nix-shell -p oci-cli --run "oci ..."

# Ex: ferramentas de build
nix-shell -p gradle jdk21 --run "gradle assembleRelease"

# Ex: Python com pacotes
nix-shell -p python3 python3Packages.requests --run "python3 script.py"

# Se o projeto tem flake.nix ou shell.nix com devShell:
nix develop
```

Pacotes instalados via `nix-shell` não persistem — isso é intencional.

---

## 9. Home Manager

O Home Manager está **embutido no módulo NixOS** — não existe `home-manager switch` separado. Para aplicar mudanças em `home/ltadeu6.nix`:

```bash
sudo nixos-rebuild switch --flake .#Nixos
```

Arquivos em `configs/` são a fonte de verdade para apps — o Home Manager os publica em `~/.config/`. Nunca edite os arquivos em `~/.config/` diretamente.

---

## 10. Adicionando serviços ou pacotes

### No sistema local (`Nixos`)
- Pacotes do sistema: `environment.systemPackages` em `hosts/Nixos/configuration.nix`
- Pacotes do usuário: `home.packages` em `home/ltadeu6.nix`
- Serviços: `services.<nome>.enable = true` em `hosts/Nixos/configuration.nix`

### No VPS (`NixOracle`)
- Edite `hosts/NixOracle/configuration.nix`
- Deploy com `./deploy-oracle.sh`

---

## 11. Validação antes de rebuild

```bash
# Verifica sintaxe Nix
nix-instantiate --parse hosts/Nixos/configuration.nix
nix-instantiate --parse home/ltadeu6.nix

# Build completo sem aplicar (mais lento, mais fiel)
nix build --print-out-paths '.#nixosConfigurations."Nixos".config.system.build.toplevel' --no-link
```

---

## 12. Regras invioláveis

- Nunca edite `hardware-configuration.nix` sem pedido explícito.
- Nunca imprima conteúdo de `/run/agenix/*` ou `.age`.
- Nunca edite arquivos em `/etc`, `/run`, `~/.config` gerados pelo sistema — edite a fonte Nix.
- Nunca faça commit de secrets em texto claro.
- Sempre use `./deploy-oracle.sh` para o NixOracle — nunca `nixos-rebuild` direto em produção.
- Se não encontrar um pacote, use `nix-shell -p <pacote>` antes de qualquer outra alternativa.
