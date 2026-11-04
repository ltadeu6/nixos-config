# Tarefas enviadas pelo Nextcloud: o servico vigia os arquivos do usuario no
# NixOracle por ssh; quando chega algo novo, baixa, faz uma triagem com
# `claude -p` e, se for tarefa, abre um agente Claude interativo (Remote Control
# ligado) num kitty no workspace 9. Detalhes no AGENTS.md ("Tarefas do Nextcloud").
{ pkgs, ... }:

let
  nc-tarefa = pkgs.writeShellApplication {
    name = "nc-tarefa";
    runtimeInputs = [ pkgs.python3 pkgs.openssh pkgs.libnotify ];
    text = ''
      export NC_TAREFA_INSTRUCOES=${../configs/nc-tarefas/instrucoes-agente.md}
      exec python3 ${../configs/nc-tarefas/nc-tarefa.py} "$@"
    '';
  };
in
{
  home.packages = [ nc-tarefa ];

  # Sem dependencia da sessao grafica: o vigia roda sempre; abrir o terminal usa
  # `hyprctl -i 0` e, sem Hyprland, a tarefa fica "lancar" e e reaberta depois.
  systemd.user.services.nc-tarefas = {
    Unit.Description = "Vigia o Nextcloud e abre um agente Claude para tarefas novas";
    Service = {
      ExecStart = "${nc-tarefa}/bin/nc-tarefa vigiar";
      # claude, kitty e hyprctl vem do perfil do usuario e do sistema
      Environment = [
        "PATH=/etc/profiles/per-user/ltadeu6/bin:/run/current-system/sw/bin"
      ];
      Restart = "always";
      RestartSec = "60s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
