#!/bin/bash -eu
image="$1"
cache_path="$2" # e.g. ~/.cache/containers
platform="$3"   # e.g. `linux/arm64`

precached_image_dir="$cache_path/$image"
precached_image="$cache_path/$image.tar"

if [ -f "$precached_image" ]; then
  echo "Skipping $image, which was already downloaded to $precached_image!"
  exit 0
fi

crane="$(command -v crane)"
if ! mkdir -p "$(dirname "$precached_image")" &>/dev/null; then
  sudo mkdir -p "$(dirname "$precached_image")"
  crane="sudo $crane"
fi

echo "Downloading $image to $precached_image..."
# We need --annotate-ref to preserve image references in the pulled archives of digest-pinned image
# references, so that they'll be loaded into Docker correctly:
if ! $crane --platform "$platform" pull --format oci --annotate-ref "$image" "$precached_image"; then
  echo "Encountered error, trying one more time to download $image..."
  rm -f "$precached_image" || sudo rm -f "$precached_image"
  $crane --platform "$platform" pull --format oci --annotate-ref "$image" "$precached_image_dir"
  tar -cf "$precached_image" -C "$precached_image_dir" .
  rm -rf "$precached_image_dir"
fi
echo "Finished downloading $image!"
