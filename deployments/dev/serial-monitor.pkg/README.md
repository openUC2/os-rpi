# serial-monitor

This brings up a web service on port 3010 for serial debugging.

## Usage

To enable the deployment for this package, run:

```
forklift plt enable-depl dev/serial-monitor
```

Then apply your changes:

```
forklift plt apply
```

Then open port 3010 in your web browser (e.g. <http://openuc2.local:3010>).
