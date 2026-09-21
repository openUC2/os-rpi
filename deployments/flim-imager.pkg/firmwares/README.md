# Bundled ZestSC3 firmwares

The FLIM Imager server ships no firmwares: it downloads each `.flim` on demand from
[flim-labs/flim-firmwares](https://github.com/flim-labs/flim-firmwares) into `FIRMWARES_ROOT`
(`/app/data/firmwares`) the first time an experiment asks for it. A device with no internet -- or
one that loses it at the wrong moment -- then fails to start the experiment with:

    Failed to find firmware: /app/data/firmwares/imaging_plf_40_chsma_in_sysma.flim

These files are vendored so the cache is warm before the server ever starts. The `firmware-seed`
service in `deployment.compose.yml` copies them into the `flim-data` volume, and still falls back to
downloading anything this directory does not cover.

## What is here

Every combination the FLIM Imager frontend and the ImSwitch bridge can ask for with SMA wiring:

    imaging_{f,lf,plf}_{10,20,40,80}_chsma_{in,out}_sysma.flim
    imaging_{f,lf,plf}_80_100ps_chsma_{in,out}_sysma.flim
    frequency_meter.flim
    channels_detection.flim

The names are exactly what `flim-lib`'s `firmware_finder` builds. Only the `chsma`/`sysma` wiring is
vendored, because the ImSwitch bridge hardcodes `channel=sma` and `sync_connection=sma`; a USB-wired
card falls back to the on-demand download. The `_100ps` variants only exist upstream at 80 MHz.

Each file is ~2.1 MB but is a sparse FPGA bitstream that compresses about 128:1, so the whole set
costs roughly half a megabyte of git history.

## Refreshing

    base=https://raw.githubusercontent.com/flim-labs/flim-firmwares/main
    for name in *.flim; do curl -fsSL -o "$name" "$base/$name"; done

## Temporary

Vendoring binaries into the pallet is a stopgap. The firmwares belong either in the
`ghcr.io/flim-labs/flim-imager-2.0` image or behind a proper asset fileset; drop this directory once
either exists.
