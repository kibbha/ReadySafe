#!/usr/bin/env bash
# Prepare a candidate offline Protomaps-v4 region (not an automatic publication).
#
# Usage:
#   PROTOMAPS_SOURCE_URL='https://.../20261104.pmtiles' \
#     bash tools/prepare_regional_pmtiles.sh ch-leman [out-dir]
#
# Requires an independently verified, immutable Protomaps v4 source URL.
# Output stays local; no GitHub Actions, commit, release or server upload occurs.
set -euo pipefail

region="${1:-}"
destination="${2:-regional-map-output}"
source_url="${PROTOMAPS_SOURCE_URL:-}"

case "$region" in
  ch-leman) bbox="5.70,45.70,7.40,47.15" ;;
  ch-alpes) bbox="7.00,45.70,10.60,47.50" ;;
  fr-alpes) bbox="5.30,43.90,7.70,46.60" ;;
  *)
    printf 'Usage: PROTOMAPS_SOURCE_URL=https://.../<PINNED>.pmtiles %s <ch-leman|ch-alpes|fr-alpes> [output-dir]\n' "$0" >&2
    exit 2
    ;;
esac

if [[ ! "$source_url" =~ ^https://[^[:space:]]+\.pmtiles$ ]]; then
  echo 'ERROR: provide an immutable HTTPS Protomaps v4 .pmtiles source in PROTOMAPS_SOURCE_URL.' >&2
  exit 2
fi
if [[ "$source_url" =~ (latest|/v4\.pmtiles|daily) ]]; then
  echo 'ERROR: refuse mutable/latest source URL. Use an immutable dated/versioned archive.' >&2
  exit 2
fi
if ! command -v pmtiles >/dev/null 2>&1; then
  echo 'ERROR: pmtiles CLI not found. https://docs.protomaps.com/pmtiles/cli' >&2
  exit 2
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo 'ERROR: python3 is required for manifest candidate output.' >&2
  exit 2
fi

mkdir -p "$destination"
basename="$region-protomaps-v4"
temp="$destination/${basename}.partial.pmtiles"
output="$destination/${basename}.pmtiles"
manifest="$destination/${basename}.candidate.json"

if [[ -e "$output" || -e "$manifest" ]]; then
  echo 'ERROR: output exists. Use a new output directory to avoid overwrites.' >&2
  exit 2
fi
trap 'rm -f "$temp"' EXIT

echo "Extracting candidate $region from pinned Protomaps source..."
# This is an operator-approved extraction from a regional PMTiles archive,
# NOT a bulk download from the OpenFreeMap tile API.
pmtiles extract "$source_url" "$temp" --bbox="$bbox" --maxzoom=15 --download-threads=4
pmtiles verify "$temp"
pmtiles show "$temp"

# Content hash is computed AFTER extraction; it pins the exact bytes served.
python3 - "$region" "$temp" "$manifest" "$source_url" "$bbox" <<'PY'
import hashlib
import json
import pathlib
import sys

region, file_name, output_name, source_url, bbox = sys.argv[1:]
source = pathlib.Path(file_name)
with source.open('rb') as f:
    header = f.read(8)
if header != b'PMTiles\\x03':
    raise SystemExit('ERROR: candidate lacks PMTiles v3 signature')

sha = hashlib.sha256()
with source.open('rb') as f:
    for chunk in iter(lambda: f.read(1024 * 1024), b''):
        sha.update(chunk)

candidate = {
    'id': region,
    'version': 'REPLACE_WITH_IMMUTABLE_RELEASE_VERSION',
    'tile_schema': 'protomaps-v4',
    'source_build_url': source_url,
    'bbox_west_south_east_north': [float(x) for x in bbox.split(',')],
    'file': source.with_suffix('').name.replace('.partial', '') + '.pmtiles',
    'byte_length': source.stat().st_size,
    'sha256': sha.hexdigest(),
    'attribution': '© OpenStreetMap contributors · Protomaps',
    'license': 'ODbL Produced Work — confirm attribution and redistribution obligations',
    'download_url': None,
    'approved': False,
    'review_required': [
        'Verify metadata: Protomaps v4 source layers and bounds',
        'Verify on-device map style, zoom levels, paths and contours',
        'Verify licensing and attribution',
        'Upload immutable archive to controlled HTTPS host',
        'Test full airplane mode, corruption handling and storage limits',
    ]
}
pathlib.Path(output_name).write_text(
    json.dumps(candidate, indent=2, ensure_ascii=False) + '\\n',
    encoding='utf-8',
)
print(json.dumps({'bytes': candidate['byte_length'], 'sha256': candidate['sha256']}, indent=2))
PY

mv "$temp" "$output"
trap - EXIT

echo "Candidate created: $output"
echo "Unapproved manifest: $manifest"
echo 'NOT READY FOR PUBLIC DOWNLOAD. Review, host and validate before enabling the pack.'
