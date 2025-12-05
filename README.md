# rpi-imswitch-os

This is the standard operating system used on Raspberry Pi computers in openUC2 devices; we call it
"ImSwitch OS".

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
```
bash "$(forklift plt locate-file dx/setup.sh)"
```

This will set up a development environment for locally developing and testing ImSwitch on your RPi.
Note that you should only one this once per OS installation: if you run it multiple times on the
same OS installation, things might break in weird ways.

### Disabling ImSwitch on Boot 

You can change the configuration locally on your RPi by running 

```bash
forklift pallet disable-deployment imswitch
```
To apply your modified configuration, then you can either 
1) run `forklift pallet apply` or
2) run `forklift pallet stage` and then reboot

(in these commands, you can also abbreviate pallet to plt and deployment to depl, if you want)

### Integrating changes in ImSwitch

1. Commit and push your changes to the [openUC2/ImSwitch](https://github.com/openUC2/ImSwitch) repo.

2. Wait for GitHub Actions to finish automatically building a new Docker container image from your
   commit.

3. Open <https://github.com/orgs/openUC2/packages/container/package/imswitch-noqt> and find the
   tagged image version (e.g.
   [sha-0c335c4](https://github.com/orgs/openUC2/packages/container/imswitch-noqt/557815319?tag=sha-0c335c4))
   corresponding to the commit you just pushed (e.g.
   [0c335c4](https://github.com/openUC2/ImSwitch/commit/0c335c4a0383a7feb75dff531706de7397402140))

4. In this repo, manually edit the
   [deployments/imswitch.pkg/compose.yml](./deployments/imswitch.pkg/compose.yml)
   file's `services.imswitch-noqt.image` value.

   It should be of format `ghcr.io/openuc2/imswitch-noqt:{something}`, and you should replace the
   `{something}` (which may look like `sha-0c335c4` or like `sha-0c335c4@sha256:{a very long hash}`)
   with the tagged image version (e.g. `sha:0c335c4`). The result should look something like:

   ```
   image: ghcr.io/openuc2/imswitch-noqt:sha-0c335c4
   ```

   If the ImSwitch container image you want to use is the most-recently-built container image in any
   branch of the openUC2/ImSwitch repo, then
   you could instead just manually trigger a run of this repo's
   [updatecli-compose action](https://github.com/openUC2/rpi-imswitch-os/actions/workflows/updatecli-compose.yml)
   and then merge the pull request which that action should create. This way, you wouldn't have to
   manually edit any files.

5. If you made your edits directly in the local pallet on a machine running ImSwitch OS (i.e. you
   edited files inside `/home/pi/.local/share/forklift/pallet`), then before publishing your edits
   you can test them directly on the device by running:

   ```
   forklift plt apply
   ```

6. To publish your edits as an update to be deployed on other machines, commit and push your changes
   to GitHub.

Now you are ready to deploy these changes as an OS update to a machine running ImSwitch OS.

### Deploying a published OS update to your machine

1. Once you've booted your machine into ImSwitch OS, from a terminal (either the Cockpit terminal or
   an SSH remote session) you can run the following command to upgrade the local pallet to the
   latest commit on the main branch:

   ```
   forklift plt upgrade
   ```

   If it gives you a warning that you may have changes in your local pallet which have not been
   committed/pushed up to GitHub, but you're sure that you won't lose any important changes by
   wiping your local pallet, then you should run:

   ```
   forklift plt upgrade --force
   ```

2. To apply all changes in the upgraded local pallet (including changes to OS configuration files),
   you should reboot.

   To immediately apply changes to Docker apps before you reboot, you can run:

   ```
   sudo systemctl restart forklift-apply
   ```

   If you are in an SSH session or you are in a GNU screen or byobu session in the Cockpit terminal,
   the following command will also work instead as an equivalent substitute to the above command:

   ```
   forklift stage apply
   ```

### Migrating from github.com/openUC2/pallet

The pallet in this repo used to be called `github.com/openUC2/pallet`. On machines deployed with
older versions of this OS built before November 2025 (i.e. versions of the OS built by the
now-archived [openUC2/imswitch-os](https://github.com/openUC2/imswitch-os) repo), you
will need to run the following command (instead of `forklift plt upgrade`) for your next upgrade:

```
forklift plt switch github.com/openUC2/rpi-imswitch-os@main
```

If it gives you a warning that you may have changes in your local pallet which have not been
committed/pushed up to GitHub, but you're sure that you won't lose any important changes by
wiping your local pallet, then you should run:

```
forklift plt switch --force github.com/openUC2/rpi-imswitch-os@main
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
