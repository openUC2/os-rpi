#!/bin/bash -eu
image="$1"
platform="$2" # e.g. `linux/arm64`

# Note: we use the Docker CLI (rather than Forklift's own image download) so that registry
# credentials from $DOCKER_CONFIG (if any) can be used for private container image repositories.
echo "Pulling $image..."
sudo -E docker pull --quiet --platform "$platform" "$image"
