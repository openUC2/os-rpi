#!/bin/bash -eu
# Makes this machine an Arkitekt robot controller: ImSwitch off, the Fairino and Opentrons
# services on. Each service waits on its page (http://<this machine>/fairino/, /opentrons/) until
# its robot is set in config.yaml and it is bound to an Arkitekt server.
#
# The os-rpi-arkitekt SD card image runs this while it is built. On a machine with the standard
# image, or after `forklift plt upgrade --force` has reset the pallet, run:
#   bash "$(forklift plt locate-file arkitekt/setup.sh)" && forklift plt stage
# then reboot (or `sudo systemctl restart forklift-apply`).
# Only one robot here? `forklift plt disable-depl opentrons` (or fairino) and stage again.

forklift plt disable-depl imswitch
forklift plt enable-depl fairino
forklift plt enable-depl opentrons
