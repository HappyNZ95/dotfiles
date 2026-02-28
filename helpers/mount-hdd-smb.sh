#!/usr/bin/env bash
set -euo pipefail

SERVER="desktop" # or 100.77.63.112
SHARE="hdd"
MOUNTPOINT="/mnt/hdd"
CRED_FILE="$HOME/.smb-cred"
FSTAB_LINE="//$SERVER/$SHARE  $MOUNTPOINT  cifs  credentials=$CRED_FILE,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775,vers=3.0,_netdev,noatime  0  0"

echo "== SMB setup =="

# ---- ask credentials ----
read -rp "SMB username: " SMB_USER
read -rsp "SMB password: " SMB_PASS
echo

# ---- create credentials file ----
cat >"$CRED_FILE" <<EOF
username=$SMB_USER
password=$SMB_PASS
EOF

chmod 600 "$CRED_FILE"
echo "✓ credentials saved to $CRED_FILE"

# ---- install deps (Arch safe) ----
if ! command -v mount.cifs >/dev/null; then
  echo "Installing cifs-utils..."
  sudo pacman -S --needed --noconfirm cifs-utils
fi

# ---- mount dir ----
sudo mkdir -p "$MOUNTPOINT"

# ---- add fstab entry if missing ----
if ! grep -qs "//$SERVER/$SHARE" /etc/fstab; then
  echo "Adding fstab entry..."
  echo "$FSTAB_LINE" | sudo tee -a /etc/fstab >/dev/null
else
  echo "fstab entry already exists"
fi

# ---- mount now ----
sudo mount -a

echo "✓ mounted at $MOUNTPOINT"
