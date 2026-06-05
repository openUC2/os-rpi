#!/bin/bash -eux
# The Forklift pallet github.com/PlanktoScope/pallet-standard provides the standard configuration of
# Forklift package deployments of Docker containerized applications, OS config files, and systemd
# system services for the PlanktoScope software distribution. This script integrates that pallet
# into the PlanktoScope OS's filesystem by installing Forklift and providing some systemd units
# which set up bind mounts and overlay filesystems to bootstrap the configs managed by Forklift.

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

pallet_upgrade_version_query="$1"

# Install Forklift
"$config_files_root/download-forklift.sh" "/usr/bin"

# Add the necessary systemd units
sudo cp "$config_files_root"/usr/lib/systemd/system/* /usr/lib/systemd/system/
sudo cp "$config_files_root"/usr/lib/systemd/system-preset/* /usr/lib/systemd/system-preset/

# Make the stage store at /var/lib/forklift/stages available for easy access in the root user's
# default Forklift workspace, both in the current boot and subsequent boots:
mkdir -p "$HOME/.local/share/forklift/stages"
sudo mkdir -p /var/lib/forklift/stages
sudo systemctl enable "bind-.local-share-forklift-stages@home-$USER.service"
if ! sudo systemctl start "bind-.local-share-forklift-stages@home-$USER.service" 2>/dev/null; then
  TARGET_UID="$(stat -c "%u" "$HOME")"
  sudo mount --bind -o X-mount.idmap="0:$TARGET_UID:1" \
    /var/lib/forklift/stages "$HOME/.local/share/forklift/stages"
  ls -l "$HOME/.local/share/forklift"
fi

# Stage the local pallet
forklift plt stage --cache-img=false
forklift stage add-bundle-name factory-reset next

# Set up Forklift upgrade checks
# TODO: add a forklift command to print the pallet path of the dev pallet, so that we won't need to
# install yq to do the same thing (maybe we can add a `forklift plt locate` command, and add a
# `forklift plt query-yaml {query} {file}` command which just uses yaml?)
echo "Downloading temporary tool to set pallet upgrade query..."
tmp_bin="$(mktemp -d --tmpdir=/tmp bin.XXXXXXX)"
"$config_files_root/download-yq.sh" "$tmp_bin"
export PATH="$tmp_bin:$PATH"

pallet_path="$(yq '.pallet.path' "$HOME/.local/share/forklift/pallet/forklift-pallet.yml")"
forklift pallet set-upgrade-query "$pallet_path@$pallet_upgrade_version_query"

# Pre-download container images without Docker

echo "Downloading temporary tools to pre-download container images..."
"$config_files_root/download-crane.sh" "$tmp_bin"
"$config_files_root/download-rush.sh" "$tmp_bin"

echo "Pre-downloading container images..."
container_platform="linux/$(
  dpkg --print-architecture | sed -e 's~armhf~arm/v7~' -e 's~aarch64~arm64~'
)"
forklift plt ls-img |
  rush "$config_files_root/precache-image.sh" \
    {} "$HOME/.cache/forklift/containers/docker-archives" "$container_platform"

echo "Preparing to load pre-downloaded container images..."
"$config_files_root/ensure-docker.sh"

echo "Loading pre-downloaded container images..."
forklift plt ls-img |
  rush "$config_files_root/load-precached-image.sh" \
    {} "$HOME/.cache/forklift/containers/docker-archives"

# Prepare to apply the local pallet on the next boot
# FIXME: containerd or runc always fails when we try to create containers (at least in a
# systemd-nspawn container), so we can't run `forklift stage apply here`

export FORKLIFT_STAGE_STORE=/var/lib/forklift/stages
sudo -E forklift stage plan
sudo -E forklift stage set-next next

# Use forklift on future boot sequences
sudo systemctl preset forklift-apply.service
# Set up read-write filesystem overlays with forklift-managed layers for /etc and /usr
# (see https://docs.kernel.org/filesystems/overlayfs.html):
sudo systemctl preset \
  bindro-run-forklift-stages-current.service \
  overlay-usr.service \
  overlay-etc.service \
  start-overlaid-units.service \
  fake-hwclock-overlay-support.service
# Set up configurability of overlay-usr & overlay-etc behavior
file="/boot/firmware/sysroot-mounts/README.md"
sudo mkdir -p "$(dirname "$file")"
sudo cp "$config_files_root$file" "$file"
