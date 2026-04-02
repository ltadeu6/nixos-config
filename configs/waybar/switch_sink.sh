#!/usr/bin/env sh

# Cycle default sink and move existing inputs.
if ! command -v pactl >/dev/null 2>&1; then
  exit 1
fi

current="$(pactl get-default-sink 2>/dev/null)"
[ -z "$current" ] && exit 1

sinks="$(pactl list short sinks | awk '{print $2}')"
[ -z "$sinks" ] && exit 1

next=""
found=0
for s in $sinks; do
  if [ "$found" -eq 1 ]; then
    next="$s"
    break
  fi
  if [ "$s" = "$current" ]; then
    found=1
  fi
done

# If current is last or not found, wrap to first.
if [ -z "$next" ]; then
  next="$(printf '%s\n' "$sinks" | head -n 1)"
fi

pactl set-default-sink "$next" || exit 1

# Move existing audio streams to the new sink.
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
  pactl move-sink-input "$input" "$next" >/dev/null 2>&1 || true
done
