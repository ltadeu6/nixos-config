# Correcao da "mira travada" do TF2 (bug do SDL 3.4.14 sob Xwayland).
#
# Causa raiz (SDL upstream #16163, corrigido no SDL 3.4.18 pelo PR #16267):
#   O TF2 64-bit roda no Steam Linux Runtime "sniper", que traz sdl2-compat
#   sobre SDL 3.4.14. No caminho XInput2, o SDL guarda em cache o modo dos
#   eixos (relativo/absoluto) do ponteiro MESTRE ("Virtual core pointer"),
#   consultado uma unica vez, no primeiro evento bruto que o processo ve. Sob
#   o Xwayland o mestre alterna entre dois escravos: xwayland-pointer (Abs X/Y)
#   e xwayland-relative-pointer (Rel X/Y). Se nesse primeiro evento o mestre
#   estava copiando o absoluto, o SDL passa a tratar os deltas relativos como
#   posicoes e entrega (delta atual - delta anterior): mouse em velocidade
#   constante vira zero. Fica assim ate fechar o jogo -- por isso e
#   intermitente entre sessoes e nada dentro do jogo recupera.
#
# Correcao: a mesma biblioteca da Valve com 1 byte trocado. O cache passa a ser
# indexado por rawev->sourceid (o escravo, cujo modo nunca muda) em vez de
# rawev->deviceid (o mestre) -- a mesma ideia do PR upstream #16259. O jogo
# carrega a copia pelo override oficial do SDL, na opcao de lancamento do TF2
# no Steam (fora do Nix; ver AGENTS.md):
#
#   SDL3_DYNAMIC_API=/home/ltadeu6/.local/share/tf2-sdl-fix/libSDL3.so.0
#
# A copia precisa ser um ARQUIVO REAL no $HOME: o container do pressure-vessel
# nao monta /nix/store, entao um symlink do Home Manager falharia em silencio
# (o SDL loga "Couldn't load an overriding SDL library" e usa o bugado).
#
# Remover quando o runtime sniper trouxer SDL >= 3.4.18.
{ lib, pkgs, ... }:

let
  sdlDeb = pkgs.fetchurl {
    url = "https://repo.steampowered.com/steamrt3/apt/pool/main/libs/libsdl3/libsdl3-0_3.4.14%2Bds-1%2Bsteamrt3.1%2Bbsrt3.1_amd64.deb";
    hash = "sha256-h0Sb+3C4GRx3i6h5WWSZg6JhO2TID1hXAuYQSLEYgNU=";
  };

  # 0x1ad883 e o `mov r13d, DWORD PTR [rbx+0x30]` (rawev->deviceid) no handler
  # de XI_RawMotion deste build exato; o ultimo byte vira 0x34 (sourceid). Os
  # dois sha256 garantem que o byte so e trocado nesse binario e que a saida e
  # identica a que foi testada.
  patchedSdl = pkgs.runCommand "libSDL3-3.4.14-steamrt-sourceid" {
    nativeBuildInputs = [ pkgs.binutils ];
  } ''
    ar x ${sdlDeb} data.tar.xz
    tar -xf data.tar.xz ./usr/lib/x86_64-linux-gnu/libSDL3.so.0.4.14
    lib=usr/lib/x86_64-linux-gnu/libSDL3.so.0.4.14
    echo "4f0b58199bb42cf428e2494db80902613c65a55a3aaf133756c17ff6d38e4a1f  $lib" | sha256sum -c -
    test "$(od -An -tx1 -j $((0x1ad883)) -N4 "$lib" | tr -d ' \n')" = "448b6b30"
    cp "$lib" "$out"
    chmod u+w "$out"
    printf '\x34' | dd of="$out" bs=1 seek=$((0x1ad886)) conv=notrunc status=none
    echo "df8e150e6f3d8524d7a8b2a7a02dc34d9c016445a5af3a273687cb451eeaf32c  $out" | sha256sum -c -
  '';
in

{
  home.activation.tf2SdlFix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    dest="$HOME/.local/share/tf2-sdl-fix/libSDL3.so.0"
    mkdir -p "$(dirname "$dest")"
    if ! ${pkgs.diffutils}/bin/cmp -s ${patchedSdl} "$dest"; then
      rm -f "$dest"
      ${pkgs.coreutils}/bin/install -m 0644 ${patchedSdl} "$dest"
    fi
  '';
}
