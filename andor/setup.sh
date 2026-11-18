#!/usr/bin/env bash
# Set up Andor SDK2 cameras (iXon) on openUC2 OS:
#   1. enables the imswitch deployment's andor-cameras feature (the andor-server sidecar),
#   2. switches a Raspberry Pi 5 to the 4K-page kernel, which andor-server's x86_64 emulator
#      needs (this reboots; run the script again afterwards),
#   3. installs the Andor SDK into andor-server (POST /andor/sdk).
#
#   bash "$(forklift plt locate-file andor/setup.sh)"                   # SDK from the release
#   bash "$(forklift plt locate-file andor/setup.sh)" andor-2.x.tar.gz  # SDK from a local archive
#
# The Andor SDK is licensed, not redistributable, so it is not in this repo. Without a local
# archive, it is downloaded from the private release $REPO@$TAG, which needs a GitHub token with
# read access to that repo (fine-grained: Contents read; classic: repo scope). Set GITHUB_TOKEN or
# type it in when asked; it is not stored.
set -euo pipefail
REPO=openUC2/andor-arm64-emulator TAG=v1.0.0 ASSET=andor-sdk.zip
ANDOR=${ANDOR_URL:-http://localhost/andor}

[ "$(id -u)" -ne 0 ] || { echo "run as the pi user, not with sudo"; exit 1; }
command -v forklift >/dev/null || { echo "forklift not found: this is for openUC2 OS"; exit 1; }

# 1. feature, staged for the next boot (applied in step 3 if no reboot is needed)
deploy=$(forklift plt locate-file deployments/imswitch.deploy.yml)
if ! grep -q 'andor-cameras' "$deploy"; then
  echo "== enabling imswitch/andor-cameras"
  forklift plt enable-depl-feat imswitch andor-cameras
  forklift plt stage
  staged=1
fi

# 2. Pi 5: 16K-page kernel by default; the emulator needs 4K pages
if [ "$(getconf PAGESIZE)" != 4096 ]; then
  echo "== switching to the 4K-page kernel (kernel=kernel8.img in /boot/firmware/config.txt)"
  grep -q '^kernel=kernel8.img' /boot/firmware/config.txt ||
    echo 'kernel=kernel8.img' | sudo tee -a /boot/firmware/config.txt >/dev/null
  echo ">>> rebooting now; run this script again afterwards"
  sudo reboot
  exit 0
fi

# 3. andor-server running?
if [ -n "${staged:-}" ] || ! docker ps --format '{{.Names}}' | grep -q andor-server; then
  echo "== applying the staged pallet"
  forklift stage apply
fi
echo "== waiting for andor-server at $ANDOR"
# /healthz is 503 until an SDK is installed, so wait for /status instead
for _ in $(seq 90); do curl -sf "$ANDOR/status" >/dev/null && break; sleep 2; done
status=$(curl -sf "$ANDOR/status") || { echo "andor-server does not answer at $ANDOR/status"; exit 1; }
if ! grep -q 'no Andor SDK' <<<"$status"; then
  echo "andor-server already has an SDK:"; echo "$status"; exit 0
fi

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

# 4. the SDK archive: argument, else the private release
if [ $# -ge 1 ]; then
  sdk=$1
  [ -f "$sdk" ] || { echo "no such file: $sdk"; exit 1; }
else
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "A GitHub token with read access to $REPO is needed (https://github.com/settings/tokens)."
    read -rsp "GitHub token: " GITHUB_TOKEN </dev/tty; echo
  fi
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28")
  # a private repo's browser download URL ignores tokens: go through the API
  asset_url=$(curl -sf "${auth[@]}" "https://api.github.com/repos/$REPO/releases/tags/$TAG" |
    python3 -c 'import json,sys; print(next(a["url"] for a in json.load(sys.stdin)["assets"] if a["name"]==sys.argv[1]))' "$ASSET") ||
    { echo "cannot read release $TAG of $REPO: wrong token, no access, or no $ASSET"; exit 1; }
  echo "== downloading $ASSET"
  curl -fL --progress-bar "${auth[@]}" -H "Accept: application/octet-stream" -o "$work/$ASSET" "$asset_url"
  sdk=$work/$ASSET
fi

# andor-server takes .tar.gz/.tgz/.tar: use a tarball inside a zip, or repack the zip
case "$sdk" in
  *.zip)
    unzip -q "$sdk" -d "$work/unz"
    inner=$(find "$work/unz" -type f \( -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar' \) | head -n1)
    if [ -n "$inner" ]; then sdk=$inner
    else tar -czf "$work/andor-sdk.tar.gz" -C "$work/unz" . && sdk=$work/andor-sdk.tar.gz; fi ;;
esac

# 5. install
echo "== installing $(basename "$sdk") into andor-server"
curl -f --data-binary @"$sdk" -H 'Content-Type: application/octet-stream' "$ANDOR/sdk"; echo
curl -s "$ANDOR/status"; echo
