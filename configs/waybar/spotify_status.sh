#!/usr/bin/env sh
# Modulo custom da waybar com a musica em reproducao.
#
# `-p spotifyd,spotify` e a lista de prioridade do playerctl. O padrao antigo
# procurava `^spotifyd\.instance` com `playerctl -l`, mas o nome MPRIS do
# spotifyd desta versao e apenas `spotify` (confirmado em
# `org.mpris.MediaPlayer2.spotify` no barramento) -- por isso o modulo ficava
# vazio mesmo com musica tocando. A lista cobre os dois nomes.
#
# Deliberadamente nao cai em qualquer player: a Zen tambem expoe MPRIS, e
# qualquer video do YouTube apareceria na barra como se fosse musica.
set -eu

PLAYERS=spotifyd,spotify

status="$(playerctl -p "$PLAYERS" status 2>/dev/null || true)"
text="$(playerctl -p "$PLAYERS" metadata --format '{{artist}} - {{title}}' 2>/dev/null || true)"

[ -n "$text" ] || exit 0

# Glifos embutidos e nao `printf '\uXXXX'`: aquilo depende do /bin/sh ser
# bash (o dash nao interpreta \u e imprimiria a sequencia literal).
case "$status" in
  Playing) printf ' %s\n' "$text" ;;
  Paused)  printf ' %s\n' "$text" ;;
  *)       exit 0 ;;
esac
