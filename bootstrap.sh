#!/bin/bash
set -euo pipefail

ask() {
  # $1 = prompt
  while true; do
    read -rp "$1 [y/n]: " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

# desktop environment
if ask "Install desktop environment and themes?"; then
  sudo pacman -S --noconfirm --needed wl-clipboard hyprland hyprshot
  paru -S noctalia-shell-git
  paru -S --noconfirm --needed qt6ct adw-gtk-theme nwg-look nemo
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi

# storage
if ask "Mount HDD at /mnt/hdd?"; then
  sudo mkdir -p /mnt/hdd
  if ! mountpoint -q /mnt/hdd; then
    sudo mount /dev/sda1 /mnt/hdd
    echo 'UUID=be3712c8-f3a7-493c-800b-7766a3f05716 /mnt/hdd ext4 defaults,noatime 0 2' | sudo tee -a /etc/fstab
  fi
  sudo pacman -S --noconfirm --needed samba
  ./helpers/create-hdd-fileshare.sh
  sudo systemctl enable --now smb
fi
sudo pacman -S --noconfirm --needed cifs-utils
mkdir -p ~/hdd
sudo mount -t cifs //desktop/hdd ~/hdd -o guest,vers=3.0

# browser
if ask "Install browsers?"; then
  sudo pacman -S --noconfirm --needed librewolf zen-browser-bin
  paru -S --noconfirm --needed python-pywalfox
fi

# dev tools
if ask "Install developer tools?"; then
  sudo pacman -S --noconfirm --needed github-cli lazygit lazydocker tree stow lxc lxd fzf
  ./helpers/setup-zoxide-fish.sh
fi

# neovim
if ask "Install Neovim and clipboard support?"; then
  sudo pacman -S --noconfirm --needed neovim wl-clipboard
fi

# misc apps
if ask "Install miscellaneous apps?"; then
  sudo pacman -S --noconfirm --needed localsend yazi obsidian ark
  paru -S --noconfirm --needed fff
  sudo ufw allow 53317/tcp
  sudo ufw allow 53317/udp
fi

# gaming
if ask "Install gaming packages?"; then
  sudo pacman -S --noconfirm --needed cachyos-gaming-meta cachyos-gaming-applications
  paru -S --noconfirm --needed xpadneo-dkms-git
  sudo modprobe hid-xpadneo
fi

# switch emulator
if ask "Install Eden (Switch emulator) and sync NAND?"; then
  paru -S --noconfirm --needed eden-bin
  rm -rf /home/htw/.local/share/eden/nand/
  mkdir -p /home/htw/.local/share/eden/nand
  rsync -a --progress --delete /mnt/hdd/media/roms/switch/bios/nand/. /home/htw/.local/share/eden/nand/
fi

# dotfiles
if ask "Clone and stow dotfiles?"; then
  DOTFILES_DIR=~/dotfiles

  # clone if missing, otherwise pull latest
  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    git clone https://github.com/HappyNZ95/dotfiles.git "$DOTFILES_DIR"
  else
    cd "$DOTFILES_DIR"
    git pull
  fi

  cd "$DOTFILES_DIR"

  # stow all packages
  for pkg in */; do
    # remove any existing target directories before stowing
    TARGET_DIR="$HOME/.config/${pkg%/}"
    if [ -d "$TARGET_DIR" ] || [ -f "$TARGET_DIR" ]; then
      echo "Removing existing $TARGET_DIR..."
      rm -rf "$TARGET_DIR"
    fi

    stow "$pkg"
  done
fi

#Log in to github
if ask "login to GitHub?"; then
  gh auth login
fi

if ask "Install tailscale"; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# Google Chrome
if ask "Install work apps?"; then
  paru -S --noconfirm --needed google-chrome
  sudo pacman -S wine-mono
  ./installConsole-arch.sh
fi
echo "Setup finished!"
if ask "Restart computer?"; then
  reboot
fi
