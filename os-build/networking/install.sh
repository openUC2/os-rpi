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
# FIXME: instead have the user set the wifi country via a first-launch setup wizard, and do it
# without using raspi-config. It should also be updated if the user changes the wifi country.
# Or maybe we don't need to set the wifi country?
if command -v raspi-config &>/dev/null; then
  sudo raspi-config nonint do_wifi_country DE
else
  echo "Warning: raspi-config is not available, so we can't set the wifi country!"
fi

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
