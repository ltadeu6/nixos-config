#! /usr/bin/env nix-shell
#! nix-shell -i bash -p oci-cli

set -euo pipefail

MAX_BACKUPS=4
# Cota do Always Free: 5 backups de volume na conta inteira (boot + block,
# todos os hosts). Backups em TERMINATING ainda contam.
ACCOUNT_BACKUP_LIMIT=5

# Estados que ocupam cota: tudo menos TERMINATED.
LIVE='[?"lifecycle-state"!=`TERMINATED`]'

oci_cmd() {
  oci "$@" --auth api_key
}

# Lê tenancy do config local (criptografado no repo)
COMPARTMENT_ID=$(awk -F'=' '/^tenancy/ { gsub(/ /, "", $2); print $2 }' ~/.oci/config)

echo "==> Localizando instância..."
INSTANCE_ID=$(oci_cmd compute instance list \
  --compartment-id "$COMPARTMENT_ID" \
  --display-name "vm" \
  --lifecycle-state RUNNING \
  --query 'data[0].id' \
  --raw-output)

AD=$(oci_cmd compute instance get \
  --instance-id "$INSTANCE_ID" \
  --query 'data."availability-domain"' \
  --raw-output)

BOOT_VOLUME_ID=$(oci_cmd compute boot-volume-attachment list \
  --compartment-id "$COMPARTMENT_ID" \
  --instance-id "$INSTANCE_ID" \
  --availability-domain "$AD" \
  --query 'data[0]."boot-volume-id"' \
  --raw-output)

echo "    Boot volume: $BOOT_VOLUME_ID"

# --- Pruning ---
echo "==> Verificando snapshots existentes..."
mapfile -t OLD_IDS < <(
  oci_cmd bv boot-volume-backup list \
    --compartment-id "$COMPARTMENT_ID" \
    --boot-volume-id "$BOOT_VOLUME_ID" \
    --sort-by TIMECREATED \
    --sort-order ASC \
    --all \
    --query "data$LIVE.id" \
    --raw-output | python3 -c "import sys,json; [print(x) for x in json.load(sys.stdin) or []]"
)

count_live() {
  local n
  # Lista vazia: a CLI nao imprime nada.
  n=$(oci_cmd bv "$1" list --compartment-id "$COMPARTMENT_ID" --all \
    --query "length(data$LIVE)" --raw-output)
  echo "${n:-0}"
}
ACCOUNT_COUNT=$(( $(count_live boot-volume-backup) + $(count_live backup) ))

COUNT=${#OLD_IDS[@]}
echo "    $COUNT snapshot(s) deste volume; $ACCOUNT_COUNT/$ACCOUNT_BACKUP_LIMIT na conta."

# Abre espaco para a snapshot nova respeitando os dois limites.
DELETE_COUNT=$(( COUNT - MAX_BACKUPS + 1 ))
ACCOUNT_EXCESS=$(( ACCOUNT_COUNT - ACCOUNT_BACKUP_LIMIT + 1 ))
(( ACCOUNT_EXCESS > DELETE_COUNT )) && DELETE_COUNT=$ACCOUNT_EXCESS

if (( DELETE_COUNT > COUNT )); then
  echo "ERRO: cota de backups da conta cheia com snapshots de outros volumes;" >&2
  echo "      apague algum manualmente antes do deploy." >&2
  exit 1
fi

if (( DELETE_COUNT > 0 )); then
  echo "==> Removendo $DELETE_COUNT snapshot(s) antiga(s)..."
  for id in "${OLD_IDS[@]:0:$DELETE_COUNT}"; do
    echo "    Deletando: $id"
    # Espera TERMINATED: enquanto TERMINATING o backup ainda ocupa a cota e
    # o create logo abaixo falha com LimitExceeded.
    oci_cmd bv boot-volume-backup delete --boot-volume-backup-id "$id" --force \
      --wait-for-state TERMINATED >/dev/null
  done
fi

# --- Backup ---
BACKUP_NAME="nixoracle-$(date +%Y-%m-%d-%H%M)"
echo "==> Criando snapshot: $BACKUP_NAME"
oci_cmd bv boot-volume-backup create \
  --boot-volume-id "$BOOT_VOLUME_ID" \
  --display-name "$BACKUP_NAME" \
  --type INCREMENTAL \
  --query 'data.id' \
  --raw-output
echo "    Snapshot solicitada (processamento em segundo plano)."

# --- Deploy ---
echo "==> Fazendo deploy do NixOracle..."
nixos-rebuild switch --flake .#NixOracle --target-host root@tadix.dev
echo "==> Deploy concluído."
