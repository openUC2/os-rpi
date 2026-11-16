#!/bin/bash -eu
# Swaps an ImSwitch image, or a whole pallet, into this machine for a hardware test.
# restore.sh undoes it.
# Run both as the user who owns the Forklift workspace, without sudo.

mode="$1"   # either `image` or `pallet`
target="$2" # image: a tag of the ImSwitch image (e.g. `sha-7d3adda`), or a full image reference
            # pallet: a pallet path and version, e.g. `github.com/openUC2/os-rpi@<commit>`

state="$HOME/.local/state/hil"
original_stage="hil-original" # the name the applied stage gets in Forklift, for restore.sh
pallet="$HOME/.local/share/forklift/pallet"
compose_file="$pallet/deployments/imswitch.pkg/deployment.compose.yml"
export LC_ALL=C # Forklift's Git messages follow the locale; keep the log in English

if [ -e "$state" ]; then
  echo "Error: an earlier swap was not restored; run restore.sh first!"
  exit 1
fi

# restore.sh goes back to the stage which is applied now.
# A stage which is staged but not yet applied would be lost by that, so we stop here instead.
if [ "$(forklift stage locate-bundle current)" != "$(forklift stage locate-bundle next)" ]; then
  echo "Error: stage $(forklift stage show-next-index) is staged but not applied!"
  exit 1
fi

# An ImSwitch image is about 6 GB, and a full disk would break the machine for everyone.
free_gb="$(df --output=avail -BG / | tail -n 1 | tr -dc '0-9')"
if [ "$free_gb" -lt 15 ]; then
  echo "Error: only ${free_gb}G free on /, need 15G to download images!"
  exit 1
fi

# Save what restore.sh needs before we change anything.
# The file swap-started comes last: restore.sh takes it as the sign that a swap was started.
mkdir -p "$state"
cp -a "$pallet" "$state/pallet"
forklift plt show-upgrade-query >"$state/upgrade-query"
forklift stage add-bundle-name "$original_stage" current
touch "$state/swap-started"

# Stage the pallet to test
case "$mode" in
"image")
  # Same as step 4 of "Integrating changes in ImSwitch" in the README:
  # edit the image in the local pallet.
  # The ImSwitch server is the first service in the file.
  if [[ "$target" != */* ]]; then
    repository="$(grep -m 1 'image:' "$compose_file" | sed -e 's/.*image: *//' -e 's/[:@].*//')"
    target="$repository:$target"
  fi
  echo "Swapping in the image $target..."
  sed -i "0,/image:/s|image:.*|image: $target|" "$compose_file"
  forklift plt stage --cache-img=false
  ;;
"pallet")
  echo "Swapping in the pallet $target..."
  forklift plt switch --force --set-upgrade-query=false --cache-img=false "$target"
  ;;
*)
  echo "Error: unknown mode $mode, should be image or pallet!"
  rm -rf "$state" # nothing was changed yet
  exit 1
  ;;
esac

# Download the images which are not on this machine yet, and note them for restore.sh to remove.
# Note: we don't let Forklift do this (hence `--cache-img=false` above).
# Forklift would also try to download the private images which are already here, and fail.
for image in $(forklift plt ls-img); do
  if ! docker image inspect "$image" &>/dev/null; then
    echo "$image" >>"$state/pulled-images"
    docker pull --quiet "$image"
  fi
done

forklift stage apply
# A reboot in the middle of the test should come back on the original stage:
forklift stage set-next --cache-img=false "$original_stage"
echo "Swapped in $target!"
