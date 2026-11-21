# Arkitekt hub

This machine's own [Arkitekt](https://arkitekt.live) hub: rekuest (remote actions) and mikro
(images), behind a gateway on ports 2754 (HTTP) and 2755 (HTTPS). Logins and organizations stay on
a coordination server such as go.arkitekt.live. ImSwitch's Arkitekt panel and Orkestrator reach the
hub through it. The deployment is off by default.

## Enabling it

```sh
forklift plt enable-depl arkitekt-hub
forklift plt enable-depl-feat imswitch arkitekt   # ImSwitch keeps its Arkitekt login
forklift plt stage                                # downloads every image of the stack (~3 GB)
sudo reboot
```

The hub's images and data need room: on a 32 GB SD card, put `/var/lib/containerd`,
`/var/lib/docker` and `/home/pi/arkitekt` on an NVMe or a USB SSD first.

At boot, `arkitekt-hub-setup.service` writes the hub's files once into
`/home/pi/arkitekt/arkitekt-hub` (`konstruktor hub create --no-start`) and the credentials the
containers read. Forklift then starts the containers, and Docker restarts them after every reboot.
The hub is named like the machine (`hostname`). Check: `journalctl -u arkitekt-hub-setup` ends
with "ready, not connected yet", and `docker ps | grep arkitekt-hub` lists eight containers
(`rustfs_init` exits once it has created the buckets).

## After enabling it: connect the hub

Once, with an approval in a browser on any computer. Easiest from **ImSwitch**: with the
`arkitekt` feature of the `imswitch` deployment, its Arkitekt panel starts with a card *This
machine's hub*. Press **Connect hub to go.arkitekt.live**, open **Accept the hub**, sign in and
accept the hub into your organization. The card follows it to *Connected*. **Bind microscope**
then preselects this hub on ImSwitch's own approval page.

Or as pi on the machine (SSH, or the terminal at `http://<machine>/admin/cockpit`):

```sh
arkitekt-hub-connect                 # go.arkitekt.live; or name another coordination server
```

Both run `konstruktor hub connect`, show a link, and wait until rekuest, mikro and the object
store answer on port 2755 with the certificate the hub registered. rekuest, mikro and the reporter
wait for the configs this writes, then start by themselves.

How the panel does it: ImSwitch starts `arkitekt-hub-connect@<server>.service` on the host over the
system D-Bus, and reads `/home/pi/arkitekt/status/hub.json`, which the script writes (nothing
secret: name, organization, addresses, the pending link). `20-arkitekt-hub.rules` lets pi start and
stop only that unit and start `arkitekt-hub-status.service`, which refreshes the state (also at
every boot).

Then:

1. **ImSwitch:** with an `arkitekt` block in the setup file, press **Bind microscope** in its
   Arkitekt panel and keep the preselected hub on the approval page:
   ```json
   "arkitekt": {"enabled": true, "appName": "frame-<name>", "url": "https://go.arkitekt.live",
                "autoConnect": true, "useMikro": true, "uploadExperiments": true}
   ```
2. **Orkestrator:** log in at go.arkitekt.live and pick this machine's hub. On macOS allow
   Orkestrator under Settings → Privacy → Local Network. From that computer,
   `curl -k https://<machine address>:2755/mikro/ht` must print `200`.

The hub advertises the addresses the machine has when it connects (LAN, hotspot, tailnet and
`<hostname>.local`). After an address change connect again (the card's **Connect again**, or
`arkitekt-hub-connect`), or reserve the DHCP lease.

## Who owns what

- **Forklift:** the containers (`deployment.compose.yml`), the konstruktor binary and the setup unit.
- **konstruktor:** the per-machine files (configs, the gateway's certificate, keys).
- **Shared commands:** the compose project is named like the folder, so `konstruktor status`, `logs`,
  `check`, `backup` and `hub connect` act on the same containers. `hub connect` recreates them from
  konstruktor's own compose file, and the next boot hands them back to Forklift.
- **Updates:** the images move only together with the konstruktor release in `forklift-package.yml`
  and `arkitekt-hub-setup`, because that release writes the configs for them. updatecli skips this
  file.

## Moving a hub that konstruktor started

Forklift removes compose projects it does not know at every apply. So a hub started with
`konstruktor up` disappears at the next boot, although its data stays. Move it to keep its data,
identity and connection:

```sh
konstruktor down --in /home/pi/arkitekt/hub
sudo mv /home/pi/arkitekt/hub /home/pi/arkitekt/arkitekt-hub
konstruktor forget <its name in konstruktor list>
```

Then enable the deployment as above.

## Limitations

- Docker publishes 2754 and 2755 on every interface, whatever firewalld's zones say.
- Logins and token refresh need the coordination server, so the hub needs internet access.
