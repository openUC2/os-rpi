# serial-monitor

A web service at URL path `/dev/serial-monitor` for debugging serial devices.

## Usage

To enable the deployment for this package, run:

```
forklift plt enable-depl --apply dev/serial-monitor
```

Then open `/dev/serial-monitor` in your web browser (e.g. <http://openuc2.local/dev/serial-monitor>).

Note: if in the future you run `forklift plt upgrade --force`, the deployment for this package will
be reset to disabled; then you'll need to run the above command again.
