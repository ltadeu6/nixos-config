#!/usr/bin/env sh
# Modulo custom da waybar para o KDE Connect.
#
# Existe em vez de um `tray` generico: o icone do tray vem do proprio app e
# nao acompanha o tema, enquanto aqui o glifo e um so e a cor vem do CSS.
# Um glifo, detalhes no tooltip -- nada de texto na barra.
#
# `-a` lista apenas os dispositivos acessiveis; `-l` lista todos os pareados.
# Nao mostra bateria do celular porque o kdeconnect-cli desta versao nao
# expoe essa informacao (ver `kdeconnect-cli --help`).
set -eu

json_escape() { sed 's/\\/\\\\/g; s/"/\\"/g' ; }

avail="$(kdeconnect-cli -a --name-only 2>/dev/null || true)"
paired="$(kdeconnect-cli -l --name-only 2>/dev/null || true)"

if [ -n "$(printf '%s' "$avail" | tr -d '[:space:]')" ]; then
  tip="Conectado: $(printf '%s' "$avail" | paste -sd', ' -)"
  cls="connected"
else
  tip="Nenhum dispositivo acessivel"
  if [ -n "$(printf '%s' "$paired" | tr -d '[:space:]')" ]; then
    tip="$tip\nPareados: $(printf '%s' "$paired" | paste -sd', ' -)"
  fi
  cls="disconnected"
fi

# `\\n` e nao `\n`: o printf converteria `\n` numa quebra de linha real,
# o que quebra o JSON. O tooltip da waybar interpreta a sequencia escapada.
printf '{"text":"","tooltip":"KDE Connect\\n%s","class":"%s"}\n' \
  "$(printf '%s' "$tip" | json_escape)" "$cls"
