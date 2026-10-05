# Configs do TF2 versionados no repo: o mastercomfig e os overrides dele.
#
# - mastercomfig: os .vpk (base + addons) vem das releases do GitHub, com
#   versao e hash fixos abaixo. Para atualizar, troque `comfigVersion` e os
#   hashes (nix-prefetch-url --type sha256 <url>).
# - configs/tf2/comfig-custom/: preset e lista de addons do mastercomfig
#   (vira tf/custom/comfig-custom/).
# - configs/tf2/overrides/: autoexec, modules e binds por classe (vira
#   tf/cfg/overrides/). O mastercomfig executa overrides/autoexec.cfg e
#   overrides/modules.cfg no inicio, e a cada troca de classe
#   overrides/game_overrides.cfg seguido de overrides/<classe>.cfg.
#
# A pasta do jogo fica em /mnt/games, fora do $HOME, e o TF2 le esses arquivos
# de dentro do container do pressure-vessel, que nao monta /nix/store. Por isso
# a ativacao COPIA os arquivos em vez de criar symlinks. Edicoes feitas direto
# na pasta do jogo sao sobrescritas no proximo rebuild: edite aqui.
{ lib, pkgs, ... }:

let
  tfDir = "/mnt/games/SteamLibrary/steamapps/common/Team Fortress 2/tf";

  comfigVersion = "9.100.1";
  comfigVpks = {
    "mastercomfig-base.vpk" = "sha256-zavIJRhkoasu9/f/7RtE9SgQlW5HbWIYO41+PpYNhlA=";
    "mastercomfig-addon-flat-mouse.vpk" = "sha256-mQkpxHNn2Z+riys7s0pbBViJHkQnUcnk0r2vo8QVG60=";
    "mastercomfig-addon-no-tutorial.vpk" = "sha256-QsMVR1JgBxvrz6L4zb+/rMVV1wjySUc8vbj99UPM6sM=";
    "mastercomfig-addon-null-canceling-movement.vpk" = "sha256-B3pHn80lMRN4q5hF/JSAdzDLTnyh7MNbYzMURrYmXxU=";
  };

  # Arvore unica espelhando tf/: custom/*.vpk, custom/comfig-custom/..., cfg/overrides/...
  tree = pkgs.runCommand "tf2-cfg-${comfigVersion}" { } (''
    mkdir -p $out/custom $out/cfg
    cp -r ${../configs/tf2/comfig-custom} $out/custom/comfig-custom
    cp -r ${../configs/tf2/overrides} $out/cfg/overrides
  '' + lib.concatStrings (lib.mapAttrsToList (name: hash: ''
    cp ${pkgs.fetchurl {
      url = "https://github.com/mastercomfig/mastercomfig/releases/download/${comfigVersion}/${name}";
      inherit hash;
    }} $out/custom/${name}
  '') comfigVpks));
in

{
  home.activation.tf2Cfg = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    dest=${lib.escapeShellArg tfDir}
    # Disco de jogos nao montado ou TF2 nao instalado: nada a fazer.
    if [ -d "$dest" ]; then
      # subshell: os blocos de ativacao compartilham o shell, o cd nao pode vazar
      (
        cd ${tree}
        ${pkgs.findutils}/bin/find . -type f | while read -r f; do
          if ! ${pkgs.diffutils}/bin/cmp -s "$f" "$dest/$f"; then
            ${pkgs.coreutils}/bin/install -D -m 0644 "$f" "$dest/$f"
          fi
        done
      )
    fi
  '';
}
