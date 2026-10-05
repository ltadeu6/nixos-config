# Configs do TF2 (overrides do mastercomfig) versionados no repo.
#
# Fonte de verdade: configs/tf2/overrides/*.cfg. O mastercomfig executa
# overrides/autoexec.cfg e overrides/modules.cfg no inicio, e a cada troca de
# classe overrides/game_overrides.cfg seguido de overrides/<classe>.cfg.
#
# A pasta do jogo fica em /mnt/games, fora do $HOME, e o TF2 le os cfgs de
# dentro do container do pressure-vessel, que nao monta /nix/store. Por isso a
# ativacao COPIA os arquivos em vez de criar symlinks. Edicoes feitas direto na
# pasta do jogo sao sobrescritas no proximo rebuild: edite aqui.
{ lib, pkgs, ... }:

let
  overridesDir = "/mnt/games/SteamLibrary/steamapps/common/Team Fortress 2/tf/cfg/overrides";
  src = ../configs/tf2/overrides;
in

{
  home.activation.tf2Cfg = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    dest=${lib.escapeShellArg overridesDir}
    # Disco de jogos nao montado ou TF2 nao instalado: nada a fazer.
    if [ -d "$(dirname "$dest")" ]; then
      mkdir -p "$dest"
      for f in ${src}/*.cfg; do
        if ! ${pkgs.diffutils}/bin/cmp -s "$f" "$dest/$(basename "$f")"; then
          ${pkgs.coreutils}/bin/install -m 0644 "$f" "$dest/$(basename "$f")"
        fi
      done
    fi
  '';
}
