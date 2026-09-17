#!/usr/bin/env bash
set -euo pipefail

# ReadySafe Switzerland offline-map build helper.
# Requires the official Protomaps `pmtiles` CLI on PATH.
# The resulting archive is intended to be uploaded to ReadySafe-owned HTTPS
# storage; the app catalog must then contain its exact byte size + SHA-256.

SOURCE="${PROTOMAPS_SOURCE:-https://build.protomaps.com/20260917.pmtiles}"
OUT="${1:-build/maps/CH-national.pmtiles}"
MAXZOOM="${MAXZOOM:-14}"
# Switzerland + a small border margin so Geneva/Basel/Lake Geneva do not clip.
BBOX="5.75,45.75,10.70,47.95"

command -v pmtiles >/dev/null || {
  echo 'Missing pmtiles CLI. See https://docs.protomaps.com/pmtiles/cli' >&2
  exit 1
}
command -v sha256sum >/dev/null || {
  echo 'Missing sha256sum.' >&2
  exit 1
}

mkdir -p "$(dirname "$OUT")"
echo "Extracting Switzerland from: $SOURCE"
pmtiles extract "$SOURCE" "$OUT" --bbox="$BBOX" --maxzoom="$MAXZOOM"
pmtiles verify "$OUT"

BYTES="$(wc -c < "$OUT" | tr -d ' ')"
SHA256="$(sha256sum "$OUT" | awk '{print $1}')"

cat <<EOF

ReadySafe Switzerland pack built successfully.
file: $OUT
bytes: $BYTES
sha256: $SHA256

After uploading the file to ReadySafe-controlled HTTPS storage, add this entry
inside assets/maps/catalog.json (replace URL with the final immutable URL):
{
  "id": "CH-national",
  "countryCode": "CH",
  "nameKey": "country_switzerland",
  "version": "2026-09-17-z${MAXZOOM}",
  "url": "https://YOUR-READysafe-STORAGE/maps/CH-national.pmtiles",
  "bytes": $BYTES,
  "sha256": "$SHA256"
}
EOF
