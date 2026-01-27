# serial-monitor

This brings up a web service at URL path `/dev/serial-monitor` for serial debugging.

## Usage

To enable the deployment for this package, run:

```
forklift plt enable-depl dev/serial-monitor
```

Then apply your changes:

```
forklift plt apply
```

Then open `/dev/serial-monitor` in your web browser (e.g. <http://openuc2.local/dev/serial-monitor>).
