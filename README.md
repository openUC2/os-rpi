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

### Setting up Andor cameras

Andor SDK2 cameras (e.g. iXon) are driven by the `andor-server` sidecar container (the
`andor-cameras` feature of the `imswitch` deployment), which ImSwitch's `AndorServerManager` reaches
at `http://andor-server:8000`. To set it up, run:
```bash
bash "$(forklift plt locate-file andor/setup.sh)"
```

The script:
1. enables the `andor-cameras` feature and stages the change,
2. on a Raspberry Pi 5, switches to the 4K-page kernel (`kernel=kernel8.img` in
   `/boot/firmware/config.txt`), which the x86_64 emulator inside `andor-server` needs. This
   reboots the Pi: run the script again afterwards,
3. installs the Andor SDK into `andor-server`.

The Andor SDK is licensed per camera and not redistributable, so it is not part of this repo or the
container image. By default, the script downloads it from a release of the private
`openUC2/andor-arm64-emulator` repo, and asks for a
[GitHub token](https://github.com/settings/tokens) with read access to that repo (fine-grained:
"Contents: read"; classic: `repo` scope). The token is not stored; you can also pass it as
`GITHUB_TOKEN=... bash ...`. If you have the SDK archive Andor supplied with your camera, pass it
instead: `bash "$(forklift plt locate-file andor/setup.sh)" andor-2.104.30091.0.tar.gz`. You can
also upload the archive by hand on `http://<machine>/andor/`.

The SDK is kept in the `andor-sdk` Docker volume, across restarts and OS updates. The Swagger UI and
a live view of the camera are at `http://<machine>/andor/`.

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

#### Optional features of a deployment

A deployment can also have optional features. `forklift plt show-depl imswitch` lists the ones
that are enabled and the ones that are available. To switch one on or off, run:

```bash
forklift plt enable-depl-feat imswitch andor-cameras   # or: disable-depl-feat
forklift plt stage && sudo reboot                     # or: forklift plt apply
```

The change is written to `deployments/imswitch.deploy.yml` in the local pallet. Like any local
change, `forklift plt upgrade --force` overwrites it, so enable the feature again after an
upgrade, or commit it to the pallet for all machines.

Opt-in features and deployments:

| What | How to turn it on | Notes |
|---|---|---|
| Andor SDK2 cameras (iXon) | `bash "$(forklift plt locate-file andor/setup.sh)"` | See [Setting up Andor cameras](#setting-up-andor-cameras) |
| ImSwitch with Micro-Manager (pymmcore-plus) | `enable-depl-feat imswitch micromanager` | Larger ImSwitch image |
| Arkitekt hub on this machine | `enable-depl arkitekt-hub` and `enable-depl-feat imswitch arkitekt` | See [Running an Arkitekt hub](#running-an-arkitekt-hub) |
| ImSwitch's Arkitekt login kept across restarts | `enable-depl-feat imswitch arkitekt` | Also needed for the hub panel |
| HDMI output as an SLM/DMD display | `enable-depl-feat imswitch slm-display` | Changes `/boot/firmware/cmdline.txt` at the next boot. Disabling it undoes the change. Video mode: `SLM_VIDEO_MODE=HDMI-A-1:1920x1080@60D` in `/etc/imswitch-slm-display.conf` |
| FLIM imager | `enable-depl flim-imager` | |

On by default (switch off with `disable-depl-feat` or `disable-depl`):

- `imswitch` feature `processing-worker`: the
  [uc2-deconvolution](https://github.com/openUC2/uc2-deconvolution) worker runs in a sidecar
  container. ImSwitch sends it the whole-stack jobs from the OME-Zarr viewer's **Deconvolve**
  button (`IMSWITCH_PROCESSING_WORKER_URL`). It is only reachable from the ImSwitch container. It
  refuses a job that does not fit in the free memory, and the kernel kills it before ImSwitch if
  memory runs out.
- `uc2-flasher` deployment: a web flasher at `http://<machine>/uc2-flasher/` for the HAT and the
  CAN boards on the USB ports. Stop ImSwitch before you flash.

### Running an Arkitekt hub

The `arkitekt-hub` deployment runs this machine's own [Arkitekt](https://arkitekt.live) hub
(rekuest and mikro). Logins stay on a coordination server such as go.arkitekt.live. It is off by
default and needs about 3 GB of images, so on a 32 GB SD card, move Docker's storage and
`/home/pi/arkitekt` to an NVMe or USB SSD first.

```bash
forklift plt enable-depl arkitekt-hub
forklift plt enable-depl-feat imswitch arkitekt
forklift plt stage && sudo reboot
```

Then connect the hub once from ImSwitch: in the Arkitekt panel, the *This machine's hub* card has
a **Connect hub** button. Alternatively, run `arkitekt-hub-connect` as pi. Approve the hub in a
browser, then press **Bind microscope**.
[deployments/arkitekt-hub.pkg/README.md](./deployments/arkitekt-hub.pkg/README.md) has the details:
the ImSwitch setup-file block, Orkestrator, address changes, and moving a hub that konstruktor
started.

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
