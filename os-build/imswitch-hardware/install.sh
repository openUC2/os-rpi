#!/bin/bash -eu

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

# Install HIK camera driver stuff
# TODO: we probably only need the udev rules made by this, and maybe also some sysctl configs, and
# maybe also a script (which we'd run as a systemd service), in which case we should deliver those
# just via Forklift instead of baking them into the base OS image via a DEB package.

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
  HIK_ARCH="aarch64"
  HIK_SAMPLE_PATH="aarch64"
elif [ "$ARCH" = "x86_64" ]; then
  HIK_ARCH="x86_64"
  HIK_SAMPLE_PATH="64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

HIK_DEB_FILE="$(mktemp --suffix=".deb")"
curl -L "https://github.com/openUC2/ImSwitchDockerInstall/releases/download/imswitch-master/MVS-3.0.1_${HIK_ARCH}_20241128.deb" \
  >"$HIK_DEB_FILE"
sudo dpkg -i "$HIK_DEB_FILE"
