#! /usr/bin/env nix-shell
#! nix-shell -i bash -p oci-cli

set -euo pipefail

MAX_BACKUPS=4

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
    --query 'data[].id' \
    --raw-output | python3 -c "import sys,json; [print(x) for x in json.load(sys.stdin)]"
)

COUNT=${#OLD_IDS[@]}
echo "    $COUNT snapshot(s) encontrada(s)."

if [ "$COUNT" -ge "$MAX_BACKUPS" ]; then
  DELETE_COUNT=$(( COUNT - MAX_BACKUPS + 1 ))
  echo "==> Removendo $DELETE_COUNT snapshot(s) antiga(s)..."
  for id in "${OLD_IDS[@]:0:$DELETE_COUNT}"; do
    echo "    Deletando: $id"
    oci_cmd bv boot-volume-backup delete --boot-volume-backup-id "$id" --force
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
