#!/bin/bash -eux
# Freeze saves snapshots of `/boot` and `/etc` into `/usr/share/factory` to facilitate factory-reset
# functionality.
# This script needs to be run with root permissions.

mkdir -p /usr/share/factory
cp -r /boot /usr/share/factory/
cp -r /etc /usr/share/factory/
