#!/bin/bash -eu

mkdir -p ~/Downloads
cd ~/Downloads

installer_repo="github.com/openUC2/ImSwitchDockerInstall"
installer_version="master"
if [ ! -d ImSwitchDockerInstall ]; then
  git clone "https://$installer_repo" ImSwitchDockerInstall --no-checkout --filter=blob:none
fi
cd ImSwitchDockerInstall
git fetch --quiet origin "$installer_version"
git checkout --quiet "$installer_version"

# install requirements
sudo apt-get install -y git curl

echo "Install Chromium kiosk mode for ImSwitch"
chmod +x install_kiosk.sh
sudo ./install_kiosk.sh install
