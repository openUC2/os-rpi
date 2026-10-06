# os-rpi: Arkitekt robot controller pallet

**This branch (`arkitekt-service`) is a separate pallet: never merge it into `edge`.** It is
openUC2 OS for a Raspberry Pi next to a lab robot, which the Pi provides to an
[Arkitekt](https://arkitekt.live) server. ImSwitch, the openUC2 documentation and the ImSwitch
build steps (Hikrobot camera driver, CAN overlay, `dx` mode) are removed; the microscope pallet
on `edge` is unchanged. The infrastructure (networking, Caddy, Cockpit, file browser, Forklift
itself) is the same, so merge `edge` into this branch now and then to pick up its updates.

This repo is both the [Forklift](https://github.com/PlanktoScope/forklift) pallet for the OS, and
the automated build system for creating OS images which can be flashed onto SD cards for booting
Raspberry Pi computers in the OS.

## Robots

| Deployment | Robot | Container | Page |
|---|---|---|---|
| `fairino` | Fairino arm | [stainSTORM/fairinogale](https://github.com/stainSTORM/fairinogale) | `http://<machine>/fairino/` |
| `opentrons` | Opentrons OT-2 | [stainSTORM/OT2windy_service](https://github.com/stainSTORM/OT2windy_service) | `http://<machine>/opentrons/` |

Both are on by default, and the machine's home page links to them. On a robot's page:

1. Edit `config.yaml` (the robot's IP, and for the arm its stations) and press **Save and restart**.
2. Enter the Arkitekt server and press **Bind**. Open the approval link it shows in any browser and
   check the code. The login is stored, so the service reconnects after a reboot.

Each service only talks to its robot when an Arkitekt action runs, so an unused one just waits.
To switch it off, run `forklift plt disable-depl opentrons` (or `fairino`), then
`forklift plt apply`.

The config, teach points and stored login live in `/home/pi/arkitekt/<deployment>/`. To set up a
robot before the first boot, put its `config.yaml` on the SD card's boot partition, in
`init-root/as-pi/home/pi/arkitekt/<deployment>/`; it is moved into place at the next boot.

The Pi must be able to reach the robot's IP: on the same network, or on a direct cable with an
address in the robot's subnet. The OT-2's USB connection uses link-local `169.254.x.x` addresses.

To ship a new robot service version, push to its repo (GitHub Actions builds
`ghcr.io/stainstorm/<repo>:sha-<commit>`), then set that tag in
`deployments/<deployment>.pkg/deployment.compose.yml`.

## Usage

These are usage instructions for developers.

### Downloading an OS image

The `build-os-trixie` GitHub Actions workflow builds `os-rpi-arkitekt-*.img.xz` on every push to
this branch and on every PR, and keeps it as a workflow artifact. Flash it to an SD card with
[Raspberry Pi Imager](https://www.raspberrypi.com/software/). Both robot containers are baked in, so
the image works without internet at first boot.

### Deploying a published OS update to your machine

1. Once you've booted your machine into the OS, from a terminal (either the Cockpit terminal or
   an SSH remote session) you can run the following command to upgrade the local pallet to the
   latest commit on the branch the image was built from (`arkitekt-service` for images built from
   pushes to it):

   ```bash
   forklift plt upgrade
   ```

   If it gives you a warning that you may have changes in your local pallet which have not been
   committed/pushed up to GitHub, but you're sure that you won't lose any important changes by
   wiping your local pallet, then you should run:

   ```bash
   forklift plt upgrade --force
   ```

2. To apply all changes in the upgraded local pallet (including changes to OS configuration files),
   you should reboot or soft-reboot (e.g. via `sudo systemctl soft-reboot`).

   If you'd like to immediately apply changes to Docker apps before your next reboot, you can run:

   ```bash
   sudo systemctl restart forklift-apply
   ```

   If you are in an SSH session or you are in a GNU screen or byobu session in the Cockpit terminal,
   the following command will also work instead as an equivalent substitute to the above command:

   ```bash
   forklift stage apply
   ```

### Disabling/enabling functionalities

To disable a deployment on your RPi, e.g. the Opentrons service, run:

```bash
forklift plt disable-depl opentrons
```

To apply your modified configuration, then you can either

1) run `forklift plt apply`, or
2) run `forklift plt stage` and then reboot or soft-reboot (e.g. via `sudo systemctl soft-reboot`).

`forklift plt enable-depl opentrons` switches it on again. Note that `forklift plt upgrade --force`
discards such local changes.

To see the full list of deployments you can disable or enable, run `forklift plt ls-depl`. Note that
for some deployments, especially some deployments whose names begin with `provisioning/`,
`networking/`, `infra/`, and `dev/`, you will have to reboot/soft-reboot in order for changes to actually take
effect.

## Exceptional operation

### Upgrading from ancient installations

Machines running versions of os-rpi built a long time ago may be running a version of this repo's
pallet which uses Docker container image that no longer exist. Trying to upgrade the pallet from
such versions will result an error, because upgrading the pallet will require the current pallet to
ensure it has a copy of the required container images so that the current pallet can be used as a
rollback in case the next pallet turns out to be invalid, and Forklift does not yet try to detect
that a local copy of the container image exists if there is no longer any remote copy of the image.
To restore the ability to upgrade the pallet in such a circumstance, please run the following
commands:

```bash
forklift plt upgrade --force @main
# This command will result in output which looks something like:
# Downloading Docker container images specified by the last successfully-applied staged pallet bundle,
# in case the next to be applied fails to be applied...
#   {...}
#   Downloading ghcr.io/openuc2/imswitch-noqt:{...}...
#   {...}
# 2026/01/23 07:53:26 couldn't prepare staged pallet bundle {...} to be applied next:
#   couldn't cache Docker container images required by staged pallet:
#     couldn't download ghcr.io/openuc2/imswitch-noqt:{...}:
#       Error response from daemon:
#         error from registry: denied

forklift stage set-next-result success
# This command will prevent your current pallet from being used as a rollback. Warning: if the
# version you're upgrading to is broken, things will be very broken and there won't be any automatic
# rollback to a fully-working version!

forklift stage set-next next
# This command will download the Docker container images for the version you're upgrading to.

forklift stage apply && sudo systemctl soft-reboot
# Just to be safe, we should test whether the Docker Compose apps all load correctly before we
# soft-reboot to fully apply the Forklift pallet. If an error occurs here, more troubleshooting will be
# needed before it's safe to soft-reboot!
```

## Licensing

Any source code provided with this Forklift pallet is covered by the following information, except
where otherwise indicated (see also notes below on imported files & dependencies):

**Copyright openUC2 project contributors**

SPDX-License-Identifier: `MIT`

You can use the source code provided here under the
[MIT License](https://spdx.org/licenses/MIT.html).

### Imported Files & Dependencies

Forklift packages deployed by this pallet have their own software licenses, as specified in the
declaration files for those packages.
