#!/bin/bash -eux

sudo mkdir -p /boot/firmware/init-root/as-root
sudo mkdir -p /boot/firmware/init-root/as-pi

# Also set up some directory structure for easier usage:
sudo mkdir -p /boot/firmware/init-root/as-root/boot/firmware
sudo mkdir -p /boot/firmware/init-root/as-root/usr/
sudo mkdir -p /boot/firmware/init-root/as-root/etc/NetworkManager/system-connections-templates.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/NetworkManager/system-connections.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/NetworkManager/system-connections
sudo mkdir -p /boot/firmware/init-root/as-root/etc/NetworkManager/dnsmasq-shared-templates.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/NetworkManager/dnsmasq-shared.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/cockpit/origins-templates.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/cockpit/origins.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/cockpit/cockpit.conf.d
sudo mkdir -p /boot/firmware/init-root/as-root/etc/firewalld/policies
sudo mkdir -p /boot/firmware/init-root/as-root/etc/firewalld/services
sudo mkdir -p /boot/firmware/init-root/as-root/etc/firewalld/zones.d
sudo mkdir -p /boot/firmware/init-root/as-root/var/lib
sudo mkdir -p /boot/firmware/init-root/as-pi/home/pi/ImSwitchConfig/config
sudo mkdir -p /boot/firmware/init-root/as-pi/home/pi/ImSwitchConfig/imcontrol_setups
