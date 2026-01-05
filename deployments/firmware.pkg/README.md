# firmware.pkg

A web server which hosts firmware binaries for download under the `/firmware/` URL path.

## Development

To run the server using Docker Compose on your own computer (rather than with Forklift on an RPi),
run the following command within this directory:

```
docker compose -f deployment.compose.yml -f dev.compose.yml up
```

Then you can open <http://localhost:8003/firmware/> in your web browser (note: you must not omit the
trailing `/` in the URL!).
