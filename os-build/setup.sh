#!/bin/bash -eu

# Determine the base path for sub-scripts

build_scripts_root=$(dirname "$(realpath "$BASH_SOURCE")")
pallet_root="$(dirname "$build_scripts_root")"

# Set up pretty error printing

red_fg=31
blue_fg=34
bold=1

subscript_fmt="\e[${bold};${blue_fg}m"
error_fmt="\e[${bold};${red_fg}m"
reset_fmt='\e[0m'

function report_starting {
  echo
  echo -e "${subscript_fmt}Starting: ${1}...${reset_fmt}"
}
function report_finished {
  echo -e "${subscript_fmt}Finished: ${1}!${reset_fmt}"
}
function panic {
  echo -e "${error_fmt}Error: couldn't ${1}${reset_fmt}"
  exit 1
}

# Parse args

build_variant="$1"
pallet_upgrade_version_query="$2"

# Run sub-scripts

sudo apt-get update -y -o Dpkg::Progress-Fancy=0 -o DPkg::Lock::Timeout=60

description="install base tools"
report_starting "$description"
if "$build_scripts_root"/tools/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="configure system locales"
report_starting "$description"
# /run/os-setup/setup.sh: line 43: /run/os-setup/localization/config.sh: Permission denied
# make sure to run chmod +x /run/os-setup/localization/config.sh
if "$build_scripts_root"/localization/config.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="configure networking"
report_starting "$description"
if "$build_scripts_root"/networking/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="configure platform hardware"
report_starting "$description"
if "$build_scripts_root"/platform-hardware/config.sh; then
  report_finished "$description"
else
  panic "$description"
fi

# Note: we must install Docker before we perform Forklift container image loading (which requires
# either Docker or containerd, which is installed by Docker).
description="install Docker"
report_starting "$description"
if "$build_scripts_root"/docker/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="set up Forklift"
report_starting "$description"
if "$build_scripts_root"/forklift/install.sh "$pallet_upgrade_version_query"; then
  report_finished "$description"
else
  panic "$description"
fi

description="install Cockpit"
report_starting "$description"
if "$build_scripts_root"/cockpit/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="set up USB storage support"
report_starting "$description"
if "$build_scripts_root"/usb-storage/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="set up rootfs initialization during boot"
report_starting "$description"
if "$build_scripts_root"/init-root/prepare.sh; then
  report_finished "$description"
else
  panic "$description"
fi

description="set up imswitch hardware"
report_starting "$description"
if "$build_scripts_root"/imswitch-hardware/install.sh; then
  report_finished "$description"
else
  panic "$description"
fi

if [[ "$build_variant" == "dx" ]]; then

  description="set up developer mode"
  report_starting "$description"

  # Note: we need to adjust update-initramfs's behavior to make apt-get finish successfully when
  # installing things like python3-picamera2; see
  # https://github.com/PlanktoScope/PlanktoScope/pull/596 and
  # https://github.com/RPi-Distro/repo/issues/382 for details.
  adjust_initramfs_scope=false
  if grep -q 'MODULES=dep' /etc/initramfs-tools/initramfs.conf; then
    adjust_initramfs_scope=true
    sudo sed -i 's~MODULES=dep~MODULES=most~' /etc/initramfs-tools/initramfs.conf
  fi

  if "$pallet_root"/dx/setup.sh; then
    if [ "$adjust_initramfs_scope" = true ]; then
      sudo sed -i 's~MODULES=most~MODULES=dep~' /etc/initramfs-tools/initramfs.conf
    fi
    report_finished "$description"
  else
    if [ "$adjust_initramfs_scope" = true ]; then
      sudo sed -i 's~MODULES=most~MODULES=dep~' /etc/initramfs-tools/initramfs.conf
    fi
    panic "$description"
  fi

fi
