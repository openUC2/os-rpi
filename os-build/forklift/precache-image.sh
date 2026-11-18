#!/bin/bash -eu
image="$1"
cache_path="$2" # e.g. ~/.cache/containers
platform="$3"   # e.g. `linux/arm64`

precached_image="$cache_path/$image"

if [ -f "$precached_image.tar" ]; then
  echo "Skipping $image, which was already downloaded to $precached_image.tar!"
  exit 0
fi

crane="$(command -v crane)"
if ! mkdir -p "$(dirname "$precached_image")" &>/dev/null; then
  sudo mkdir -p "$(dirname "$precached_image")"
  crane="sudo $crane"
fi

echo "Downloading $image to $precached_image.tar..."
# We need --annotate-ref to preserve image references in the pulled archives of digest-pinned image
# references, so that they'll be loaded into Docker correctly:
image_ref="$(sed -e 's~@sha256:.*$~~' 's~docker.io/library/~~' <<<"$image")"
if ! $crane --platform "$platform" pull --format oci --annotate-ref "$image_ref" "$precached_image"; then
  echo "Encountered error, trying one more time to download $image..."
  rm -f "$precached_image" || sudo rm -f "$precached_image"
  $crane --platform "$platform" pull --format oci --annotate-ref "$image_ref" "$precached_image"
fi
tar -cf "$precached_image.tar" -C "$precached_image" .
rm -rf "$precached_image"
echo "Finished downloading $image!"
