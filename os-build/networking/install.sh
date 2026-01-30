#!/bin/bash -eux
# The networking configuration enables access to network services via static IP over Ethernet, and
# via self-hosted wireless AP when a specified external wifi network is not available.

# Determine the base path for copied files
config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

# Install dependencies
sudo -E apt-get install -y -o Dpkg::Progress-Fancy=0 \
  network-manager firewalld dnsmasq-base
sudo systemctl enable NetworkManager.service

# Set the wifi country
# FIXME: instead have the user set the wifi country via device-admin
if command -v raspi-config &>/dev/null; then
  sudo raspi-config nonint do_wifi_country DE
else
  echo "Warning: raspi-config is not available, so we can't set the wifi country!"
fi

# Set up USB gadget mode
sudo -E apt-get install -y -o Dpkg::Progress-Fancy=0 \
  rpi-usb-gadget
sudo cp "$config_files_root"/etc/modules-load.d/usb-gadget.conf /etc/modules-load.d/

# Install tailscale
sudo -E apt-get install -y -o Dpkg::Progress-Fancy=0 \
  apt-transport-https
DISTRO_VERSION_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
curl -fsSL "https://pkgs.tailscale.com/stable/raspbian/$DISTRO_VERSION_CODENAME.noarmor.gpg" |
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL "https://pkgs.tailscale.com/stable/raspbian/$DISTRO_VERSION_CODENAME.tailscale-keyring.list" |
  sudo tee /etc/apt/sources.list.d/tailscale.list
sudo -E apt-get update -y -o Dpkg::Progress-Fancy=0
sudo -E apt-get install -y -o Dpkg::Progress-Fancy=0 \
  tailscale

sudo usermod -aG netdev "$USER"
