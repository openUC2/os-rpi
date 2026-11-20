#!/bin/bash -eux
# Cleanup removes unnecessary files from the OS for a smaller and more secure disk image.

# Remove unnecessary packages:
sudo apt-get remove -y gcc
sudo apt-get remove -y gcc-10 || true
sudo apt-get remove -y gcc-12 || true

# Clean up any unnecessary apt files (`apt-get install` keeps every downloaded .deb):
sudo apt-get autoremove -y
sudo apt-get clean -y

# Clean up any unnecessary pip/etc. files
pip3 cache purge || true
rm -rf "$HOME/.cache/pip"

# Clear machine-id so that it will be regenerated on the next boot
# (refer to https://www.freedesktop.org/software/systemd/man/latest/machine-id.html):
sudo bash -c 'printf "" > /var/lib/dbus/machine-id'
sudo bash -c 'printf "uninitialized\n" > /etc/machine-id'

# Clear other secrets (refer to https://systemd.io/BUILDING_IMAGES/):
sudo rm -f /var/lib/systemd/random-seed
sudo rm -f /var/lib/systemd/credential.secret
sudo rm -f /var/lib/NetworkManager/secret_key

# Remove SSH keys:
sudo rm -f /etc/ssh/ssh_host_*_key*
