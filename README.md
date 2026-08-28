# os-rpi

This is the standard operating system used on Raspberry Pi computers in openUC2 devices; we call it
"openUC2 OS".

This repo is both the [Forklift](https://github.com/PlanktoScope/forklift) pallet for the OS, and
the automated build system for creating OS images which can be flashed onto SD cards for booting
Raspberry Pi computers in the OS.

## Usage

These are usage instructions for developers.

### Downloading an OS image

If you have appropriate permissions on this repo, you can download OS images from the
`build-os-bookworm` GitHub Actions CI workflow. Otherwise, you can download one of the images from
[our Google Drive archive of selected images](https://drive.google.com/drive/folders/1i5baXgEq9UAybYQGHqEnLtaQ7-Js22MK?usp=sharing).
You should flash the OS image to an SD card using
[Raspberry Pi Imager](https://www.raspberrypi.com/software/).

### Enabling `dx` (developer experience) mode

If you downloaded the basic variant of our OS images instead of the `dx` variant, you can enable
`dx` mode by running:
```bash
bash "$(forklift plt locate-file dx/setup.sh)"
```

This will set up a development environment for locally developing and testing ImSwitch on your RPi.
Note that you should only do this once per OS installation: if you run it multiple times on the
same OS installation, things might break in weird ways.

### Enabling kiosk mode

You can set up a fullscreen Chromium kiosk which boots straight into the ImSwitch web UI by running:
```bash
bash "$(forklift plt locate-file kiosk/setup.sh)"
```

System control:`sudo kioskctl {enable,disable,status,uninstall}`.

You can connect an HDMI monitor or the original DSI display. Have fun!

### Integrating changes in ImSwitch

1. Commit and push your changes to the [openUC2/ImSwitch](https://github.com/openUC2/ImSwitch) repo.

2. Wait for GitHub Actions to finish automatically building a new Docker container image from your
   commit.

3. Open <https://github.com/orgs/openUC2/packages/container/package/imswitch> and find the
   tagged image version (e.g.
   [sha-d57b561](https://github.com/orgs/openUC2/packages/container/imswitch/642900285?tag=sha-d57b561))
   corresponding to the commit you just pushed (e.g.
   [d57b561](https://github.com/openUC2/ImSwitch/commit/d57b561bc46a3fd353ea3e44f681b147e578ec4c))

4. In this repo, manually edit the
   [deployments/imswitch.pkg/deployment.compose.yml](./deployments/imswitch.pkg/deployment.compose.yml)
   file's `services.imswitch.image` value.

   It should be of format `ghcr.io/openuc2/imswitch:{something}`, and you should replace the
   `{something}` (which may look like `sha-7b9de3d` or like `sha-0c335c4@sha256:{a very long hash}`)
   with the tagged image version (e.g. `sha:d57b561`). The result should look something like:

   ```bash
   image: ghcr.io/openuc2/imswitch:sha-d57b561
   ```

   If the ImSwitch container image you want to use is the most-recently-built container image in any
   branch of the openUC2/ImSwitch repo, then
   you could instead just manually trigger a run of this repo's
   [updatecli-compose action](https://github.com/openUC2/os-rpi/actions/workflows/updatecli-compose.yml)
   and then merge the pull request which that action should create. This way, you wouldn't have to
   manually edit any files.

5. If you made your edits directly in the local pallet on a machine running openUC2 OS (i.e. you
   edited files inside `/home/pi/.local/share/forklift/pallet`), then before publishing your edits
   you can test them directly on the device by running:

   ```bash
   forklift plt apply
   ```

6. To publish your edits as an update to be deployed on other machines, commit and push your changes
   to GitHub.

Now you are ready to deploy these changes as an OS update to a machine running openUC2 OS.

### Deploying a published OS update to your machine

1. Once you've booted your machine into openUC2 OS, from a terminal (either the Cockpit terminal or
   an SSH remote session) you can run the following command to upgrade the local pallet to the
   latest commit on the `edge` branch:

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

To disable the deployment of ImSwitch on your RPi, you can change the configuration on your RPi by
running:

```bash
forklift plt disable-depl imswitch
```

To apply your modified configuration, then you can either

1) run `forklift plt apply`, or
2) run `forklift plt stage` and then reboot or soft-reboot (e.g. via `sudo systemctl soft-reboot`).

If you later want to re-enable ImSwitch, you can then run `forklift plt enable-depl imswitch` (and
then apply your modified configuration using the command(s) you prefer).

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
