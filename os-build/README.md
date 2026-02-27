# os-build

OS image build scripts for openUC2 OS

## Development

The entrypoint for the OS setup process is [`setup.sh`](./setup.sh). To add more steps to the OS
setup process, add those steps to that file. You can refer to the [`tools` step](./tools/install.sh)
for an example of installing packages with APT. You can refer to the
[`forklift` step](./forklift/install.sh) for an example of copying files from this repo into the OS
image. However, in general you should only directly copy files into the OS image if they're needed
during early boot before forklift runs; otherwise, you should deploy those files via
[github.com/openUC2/pallet](https://github.com/openUC2/pallet) (for an example of how to do this,
refer to [PR openUC2/pallet#7](https://github.com/openUC2/pallet/pull/7)).

## Licensing

### Origins

This directory was initialized as a copy of
[github.com/forklift-run/rpi-os-demo](https://github.com/forklift-run/rpi-os-demo). The rpi-os-demo
repository is under copyright of Ethan Li and Forklift project contributors, and its files have been
copied and used here under the Apache 2.0 License.

The [github.com/forklift-run/rpi-os-demo](https://github.com/forklift-run/rpi-os-demo) repository
was created by Ethan Li as a copy of a subset of original contributions which they had
donated to [github.com/PlanktoScope/PlanktoScope](https://github.com/PlanktoScope/PlanktoScope). The
PlanktoScope repository's source code is licensed under the
[GPL 3.0 License](https://www.gnu.org/licenses/gpl-3.0.en.html); because Ethan has retained
copyright ownership over their own individual contributions to the PlanktoScope repository (instead
of assigning copyright ownership to the PlanktoScope project via any legal contract or any
[work-for-hire arrangement](https://worksmadeforhire.com/) with any employer), Ethan has exercised
their legal right to make their own contributions available under additional licenses by gathering
some of their own contributions, copying them into the rpi-os-demo repository, and then making that
source code available under the Apache 2.0 License and under the Blue Oak Model License 1.0.0
(SPDX License Identifier: `Apache-2.0 OR BlueOak-1.0.0`).

### Contributions

Contributions to this directory will only be accepted if the contributor has a legal right to make
the contributed source code available in this repository under this repository's licenses
(which are listed in this repository's top-level [README.md](../README.md)). In particular, this
means that we might not be able to accept a contribution from you if it includes GPL-licensed source
code from
[github.com/PlanktoScope/PlanktoScope](https://github.com/PlanktoScope/PlanktoScope) and you are not
the author of that source code in the PlanktoScope repository, or if you otherwise lack the legal
right (e.g. via copyright ownership) to distribute that source code under this repository's
licenses.
