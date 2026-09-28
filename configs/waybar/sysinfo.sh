#!/usr/bin/env sh
# Modulo custom da waybar com o estado da maquina.
#
# Um glifo na barra e todos os numeros no tooltip, de proposito: uma fileira
# de porcentagens polui, e essa informacao e consultada de vez em quando, nao
# monitorada continuamente.
#
# A temperatura da CPU vem do k10temp (hwmon do Ryzen). A da GPU vem do
# nvidia-smi e nao do modulo `temperature` da waybar, porque aquele so le
# hwmon e a NVIDIA nao aparece por lá -- os hwmon desta maquina sao apenas
# k10temp e amdgpu (a iGPU).
set -eu

cpu_temp="?"
for h in /sys/class/hwmon/hwmon*; do
  [ "$(cat "$h/name" 2>/dev/null || true)" = "k10temp" ] || continue
  t="$(cat "$h/temp1_input" 2>/dev/null || true)"
  [ -n "$t" ] && cpu_temp="$((t / 1000))C"
  break
done

load="$(cut -d' ' -f1-3 /proc/loadavg)"

mem="$(awk '
  /^MemTotal:/     { tot = $2 }
  /^MemAvailable:/ { avail = $2 }
  END { printf "%.1f/%.1f GiB (%d%%)", (tot-avail)/1048576, tot/1048576, (tot-avail)*100/tot }
' /proc/meminfo)"

gpu="indisponivel"
if command -v nvidia-smi >/dev/null 2>&1; then
  gpu="$(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null \
    | awk -F', ' '{printf "%s  %sC  %s%%  %d/%d MiB", $1, $2, $3, $4, $5}')"
fi

disks="$(df -h --output=target,pcent,avail / /mnt/games 2>/dev/null \
  | awk 'NR>1 {printf "%s  %s usado, %s livre\\n", $1, $2, $3}')"

printf '{"text":"","tooltip":"CPU  %s  (load %s)\\nRAM  %s\\nGPU  %s\\n%s","class":"sysinfo"}\n' \
  "$cpu_temp" "$load" "$mem" "$gpu" "$disks"
