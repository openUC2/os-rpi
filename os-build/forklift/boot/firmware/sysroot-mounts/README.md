# sysroot-mounts

By default, `/sysroot/etc` and `/sysroot/usr` are mounted in read-only mode as the base of Forklift overlays for `/etc` and `/usr`, respectively.
However, in certain exceptional situations (e.g. when kernel drivers need to be installed for Wi-Fi dongles, or when doing lower-level troubleshooting of nasty issues) it is useful to directly modify `/sysroot/etc` and/or `/sysroot/usr`.

## `/sysroot/etc`

To enable direct modification of `/sysroot/etc`, run:

```bash
sudo touch /boot/firmware/sysroot-mounts/etc-rw
sudo systemctl soft-reboot
```

To disable further direct modification of `/sysroot/etc`, run:

```bash
sudo rm /boot/firmware/sysroot-mounts/etc-rw
sudo systemctl soft-reboot
```

You can always re-enable and re-disable direct modification of `/sysroot/etc` using these commands.

## `/sysroot/usr`

To enable direct modification of `/sysroot/usr`, run:

```bash
sudo touch /boot/firmware/sysroot-mounts/usr-rw
sudo systemctl soft-reboot
```

To disable further direct modification of `/sysroot/usr`, run:

```bash
sudo rm /boot/firmware/sysroot-mounts/usr-rw
sudo systemctl soft-reboot
```

You can always re-enable and re-disable direct modification of `/sysroot/usr` using these commands.
