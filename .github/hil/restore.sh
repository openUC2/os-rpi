#!/bin/bash -eu
# Puts this machine back the way swap-in.sh found it.
# Does nothing if nothing was swapped in, so it is safe to run at any time.
# If it fails, it keeps its state and can be run again.

state="$HOME/.local/state/hil"
original_stage="hil-original" # the name swap-in.sh gave the stage to go back to
pallet="$HOME/.local/share/forklift/pallet"
export LC_ALL=C # Forklift's Git messages follow the locale; keep the log in English

if [ ! -f "$state/swap-started" ]; then
  rm -rf "$state" # swap-in.sh stopped before it changed anything
  exit 0
fi

echo "Restoring the stage $original_stage..."
forklift stage set-next --cache-img=false "$original_stage"
forklift stage apply

echo "Restoring the local pallet..."
rm -rf "$pallet"
cp -a "$state/pallet" "$pallet"
if [ "$(forklift plt show-upgrade-query)" != "$(cat "$state/upgrade-query")" ]; then
  forklift plt set-upgrade-query "$(cat "$state/upgrade-query")"
fi

# Remove the images swap-in.sh downloaded.
# Docker refuses to remove one which a container still uses,
# i.e. one which the original stage needs as well.
if [ -f "$state/pulled-images" ]; then
  for image in $(cat "$state/pulled-images"); do
    docker rmi "$image" || echo "Keeping $image, which is still in use."
  done
fi

forklift stage delete-bundle-name "$original_stage"
rm -rf "$state"
echo "Restored!"
