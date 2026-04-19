#!/usr/bin/env sh

player="$(playerctl -l 2>/dev/null | rg '^spotifyd\.instance' -m1 || true)"

if [ -z "$player" ]; then
  exit 0
fi

status="$(playerctl -p "$player" status 2>/dev/null || true)"
text="$(playerctl -p "$player" metadata --format '{{artist}} - {{title}}' 2>/dev/null || true)"

if [ -z "$text" ]; then
  exit 0
fi

case "$status" in
  Playing)
    printf ' %s\n' "$text"
    ;;
  Paused)
    printf ' %s\n' "$text"
    ;;
  *)
    exit 0
    ;;
esac
