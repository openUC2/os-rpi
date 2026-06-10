#!/bin/bash -eu

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

# Add config.txt configuration for the CAN transceiver on the openUC2 HAT+
file="/boot/firmware/config.txt"
sudo bash -c "cat \"$config_files_root$file.snippet\" >> \"$file\""
