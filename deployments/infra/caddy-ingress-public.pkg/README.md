# caddy-ingress-public.pkg

An ingress proxy on port 8001 which only exposes unprivileged services.

## Use with Tailscale Funnel

To only expose unprivileged services over Tailscale Funnel, run:

```
tailscale funnel --https=8443 8001
```

Then you can access the services from the public internet on port 8443 of the domain name assigned
by Tailscale Funnel.

Warning: if you use `--https=443` or omit `--https=8443` in the above command, Tailscale Funnel will
prevent `caddy-ingress.pkg` from starting correctly when the machine boots. Don't do that!

To stop Tailscale Funnel, run:

```
tailscale funnel --https=8443 8001 off
```

