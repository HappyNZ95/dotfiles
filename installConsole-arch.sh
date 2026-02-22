#!/bin/bash

echo "Welcome to the installation script for Take Control Console."
echo "This script will install Wine (Arch Linux) and then run the Take Control Console installer."
echo "Please follow the instructions carefully."

will_install_wine=false

# Check if Wine is installed
if [ -x "$(command -v wine)" ]; then
  echo "Wine is already installed."
  echo "Make sure it is up to date (sudo pacman -Syu)."
  read -p "Do you want to continue? (y/n): " user_option

  user_option=$(echo "$user_option" | tr '[:upper:]' '[:lower:]')

  if [ "$user_option" != "y" ]; then
    echo "Aborting installation..."
    exit 1
  fi
else
  echo "Wine is not installed."
  read -p "Do you want to install Wine now? (y/n): " user_option

  user_option=$(echo "$user_option" | tr '[:upper:]' '[:lower:]')

  if [ "$user_option" = "y" ]; then
    will_install_wine=true
  else
    echo "Wine will not be installed."
    echo "Aborting installation..."
    exit 1
  fi
fi

# Install Wine on Arch
if $will_install_wine; then
  if [ -x "$(command -v pacman)" ]; then
    echo "Arch Linux detected."

    echo "Enabling multilib repository (required for 32-bit support)..."

    # Ensure multilib is enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
      echo "Multilib repository not enabled."
      echo "Please uncomment the following lines in /etc/pacman.conf:"
      echo "[multilib]"
      echo "Include = /etc/pacman.d/mirrorlist"
      echo "Then run this script again."
      exit 1
    fi

    sudo pacman -Sy --needed wine wine-mono wine-gecko

  else
    echo "Unsupported distribution. Please install Wine manually."
    exit 1
  fi
else
  echo "Continuing with existing Wine installation..."
fi

# Final Wine check
if [ -x "$(command -v wine)" ]; then
  echo "Installing Take Control Console..."
  wine BASETechConsole*.exe
  echo "Take Control Console installation finished."
  . ./protocolRegister.sh
else
  echo "Wine installation failed."
  echo "Please install Wine manually with:"
  echo "sudo pacman -S wine"
fi
