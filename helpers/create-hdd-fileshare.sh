#!/bin/bash

sudo smbpasswd -a htw
sudo tee -a /etc/samba/smb.conf >/dev/null <<'EOF'
[hdd]
   path = /mnt/hdd
   browseable = yes
   read only = no
   guest ok = yes
EOF

sudo systemctl restart smb
