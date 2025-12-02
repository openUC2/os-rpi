#!/bin/bash -eu

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

mkdir -p ~/Downloads
mkdir -p ~/Desktop
mkdir -p ~/Datasets

cd ~/Downloads

installer_repo="github.com/openUC2/ImSwitchDockerInstall"
installer_version="master"
git clone "https://$installer_repo" ImSwitchDockerInstall --no-checkout --filter=blob:none
cd ImSwitchDockerInstall
git checkout --quiet "$installer_version"

# install requirements
sudo apt-get install -y git curl

# echo "Clone ImSwitchConfig"
# ./git_clone_imswitchconfig.sh

echo "Install HIK Driver"
./install_hikdriver.sh

echo "Install Daheng Driver"
./install_dahengdriver.sh

echo "Install Python and ImSwitch natively - experimental"
./install_native.sh

echo "Install Vimba Driver"
./install_vimba.sh

echo "Create Desktop Icons"
./create_desktopicons.sh

# echo "Set install_autostart for ImSwitch"
# ./install_autostart.sh

# add serial devices to user group
sudo usermod -a -G dialout "$USER"
sudo usermod -a -G tty "$USER"
echo "Please reboot to take effect of adding serial devices to user group"

# Clean up any unnecessary pip/etc. files
pip3 cache purge || true
rm -rf "$HOME/.cache/pip"
