# TUCam save_image example

Console sample: stream warmup, then software trigger and save frames as TIFF. No Qt dependency for cross-build.

## Layout

| Path | Description |
|------|-------------|
| `save_image/main.cpp` | Example source |
| `Makefile.cross` | Cross-compile for aarch64 (links v2 `libTUCam`, v2 headers) |
| `build-rpi/save_image` | Cross-build output (created by `make -f Makefile.cross`) |

## Cross-build (dev machine)

```bash
cd scripts/rpi-cross-env
./build-v2-rpi.sh    # produces v2/TUCam/output

source ./env.sh
cd "${SDK_ROOT}/examples/save_image"
make -f Makefile.cross
file build-rpi/save_image
```

## Run on target (e.g. Raspberry Pi)

1. Install SDK: `sudo dpkg -i scripts/rpi-cross-env/dist/tucam-v2_2.0.9.0-1_arm64.deb` or tarball `install.sh`
2. Ensure `/etc/tucam/tuusb.conf` and udev rules are installed
3. Run with library path:

```bash
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
./build-rpi/save_image
```

Included in release package via `scripts/rpi-cross-env/pack-v2-rpi.sh` (default example). After `sudo ./install.sh`:

```bash
/usr/share/tucam-v2/examples/save_image/save_image
```
