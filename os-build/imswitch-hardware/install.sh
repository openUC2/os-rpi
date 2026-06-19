#!/bin/bash -eu

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

# Install HIK camera driver stuff
# Note: this adds some library files into `/opt/MVS` which are needed for ImSwitch-in-Docker to
# work, and it also installs a server launched during boot which may also be needed for
# ImSwitch-to-Docker to work.

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

# Add config.txt configuration for the CAN transceiver on the openUC2 HAT+
file="/boot/firmware/config.txt"
sudo bash -c "cat \"$config_files_root$file.snippet\" >> \"$file\""
