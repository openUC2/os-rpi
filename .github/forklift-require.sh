#!/usr/bin/env -S bash -eu

path="$1"          # path of a pallet, e.g. `github.com/openUC2/os-rpi`
version_query="$2" # version query, e.g. `edge` or `beta` or `stable; pseudoversions are not supported (yet)

prev_version="$(forklift dev pallet "show-pallet-version" "$path")"
if [ "$DRY_RUN" = "true" ]; then
  prev_version_lock="$(mktemp -t forklift-version-lock-XXXXX.yml)"
  cp "requirements/pallets/$path/forklift-version-lock.yml" "$prev_version_lock"
fi

# Note: updatecli expects that stdout should only contain the version string of the updated version,
# and it should be empty if the version was not changed.
forklift dev pallet "require-pallet" "$path@$version_query"
version="$(forklift dev pallet "show-pallet-version" "$path")"
if [ "$prev_version" != "$version" ]; then
  echo "$version"
fi

if [ "$DRY_RUN" = "true" ]; then
  cp "requirements/pallets/$path/forklift-version-lock.yml" "$prev_version_lock"
fi
