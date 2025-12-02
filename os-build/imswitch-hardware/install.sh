#!/bin/bash -eu

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

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

HIK_DEB_FILE="MVS-3.0.1_${HIK_ARCH}_20241128.deb"
wget https://github.com/openUC2/ImSwitchDockerInstall/releases/download/imswitch-master/"$HIK_DEB_FILE"
sudo dpkg -i "$HIK_DEB_FILE"
