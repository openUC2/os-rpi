#!/bin/bash -eux
# Cleanup removes unnecessary files from the operating system for a smaller disk image.

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

# Note: this script used to also reset /etc/machine-id, systemd/NetworkManager secrets, and SSH host
# keys. That was dropped when the script was first wired into the build, because nothing in this
# build regenerates SSH host keys on first boot, and an "uninitialized" machine-id makes systemd
# apply unit presets on first boot. Re-add those steps together with their first-boot counterparts.
