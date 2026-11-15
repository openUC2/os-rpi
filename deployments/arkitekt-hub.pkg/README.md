# Arkitekt hub

This machine's own [Arkitekt](https://arkitekt.live) hub: rekuest (remote actions) and mikro
(images), behind a gateway on ports 2754 (HTTP) and 2755 (HTTPS). Logins and organizations stay on
a coordination server such as go.arkitekt.live. ImSwitch's Arkitekt panel and Orkestrator reach the
hub through it. The deployment is off by default.

## Enabling it

```sh
forklift plt enable-depl arkitekt-hub
forklift plt enable-depl-feat imswitch arkitekt   # ImSwitch keeps its Arkitekt login
forklift plt stage
sudo reboot
```

At boot, `arkitekt-hub-setup.service` writes the hub's files once into
`/home/pi/arkitekt/arkitekt-hub` (`konstruktor hub create --no-start`) and the credentials the
containers read. Forklift then starts the containers, and Docker restarts them after every reboot.

Then connect the hub once (it asks for an approval in a browser):

```sh
konstruktor hub connect --in /home/pi/arkitekt/arkitekt-hub --server go.arkitekt.live
```

rekuest, mikro and the reporter wait for the configs this writes, then start by themselves.

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
