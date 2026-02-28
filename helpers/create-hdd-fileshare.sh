#!/bin/bash

sudo smbpasswd -a htw
sudo tee -a /etc/samba/smb.conf >/dev/null <<'EOF'
[hdd]
   path = /mnt/hdd
   read only = no
   valid users = htw
   force user = htw
   force group = htw
   create mask = 0664
   directory mask = 0775
EOF

sudo systemctl restart smb
