#!/bin/bash -eux

sudo mkdir -p /boot/init-root

# Also set up some directory structure for easier usage:
sudo mkdir -p /boot/init-root/usr/
sudo mkdir -p /boot/init-root/etc/NetworkManager/system-connections-templates.d
sudo mkdir -p /boot/init-root/etc/NetworkManager/system-connections.d
sudo mkdir -p /boot/init-root/etc/NetworkManager/system-connections
sudo mkdir -p /boot/init-root/etc/NetworkManager/dnsmasq-shared-templates.d
sudo mkdir -p /boot/init-root/etc/NetworkManager/dnsmasq-shared.d
sudo mkdir -p /boot/init-root/etc/cockpit/origins-templates.d
sudo mkdir -p /boot/init-root/etc/cockpit/origins.d
sudo mkdir -p /boot/init-root/etc/cockpit/cockpit.conf.d
sudo mkdir -p /boot/init-root/etc/firewalld/policies
sudo mkdir -p /boot/init-root/etc/firewalld/services
sudo mkdir -p /boot/init-root/etc/firewalld/zones.d
sudo mkdir -p /boot/init-root/var/lib
sudo mkdir -p /boot/init-root/home/pi/ImSwitchConfig/config
sudo mkdir -p /boot/init-root/home/pi/ImSwitchConfig/imcontrol_setups
