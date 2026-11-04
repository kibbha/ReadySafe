#!/usr/bin/env bash
# Create candidate 20 m contour lines from locally downloaded, licensed
# swissALTI3D GeoTIFF (not swisstopo's sample-data-only files).
#
# Usage:
#   bash tools/prepare_swiss_contours.sh ch-leman swissalti_clip.tif [output-dir]
#
# This tool does NOT fetch datasets, publish maps or approve licensing.
# The input must be a regional clip from official swisstopo OGD data.
set -euo pipefail

region="${1:-}"
source_file="${2:-}"
output_dir="${3:-regional-map-output}"

case "$region" in
  ch-leman|ch-alpes) ;;
  *)
    echo "Usage: $0 <ch-leman|ch-alpes> <swissALTI3D-OGD-clip.tif> [output-dir]" >&2
    exit 2
    ;;
esac

if [[ ! -f "$source_file" ]]; then
  echo 'ERROR: downloaded, licensed swissALTI3D GeoTIFF not found.' >&2
  exit 2
fi
case "$source_file" in
  -*)
    echo 'ERROR: use a relative ./ or absolute path to the GeoTIFF.' >&2
    exit 2
    ;;
esac

for command in gdalwarp gdal_contour ogr2ogr tippecanoe pmtiles python3; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: $command" >&2
    exit 2
  fi
done

mkdir -p "$output_dir"
out="$output_dir/${region}-contours-20m.pmtiles"
manifest="$output_dir/${region}-contours-20m.candidate.json"
if [[ -e "$out" || -e "$manifest" ]]; then
  echo 'ERROR: output exists. Choose a different output directory.' >&2
  exit 2
fi

working="$(mktemp -d "$output_dir/contours-build-XXXXXXXX")"
trap 'rm -rf "$working"' EXIT
raster="$working/20m-dem.tif"
contours_gpkg="$working/contours.gpkg"
contours_geojson="$working/contours.geojson"
archive="$working/contours.pmtiles"

echo 'Resampling input DEM to 20-metre grid in EPSG:3857...'
# swissALTI3D source is LV95/LN02. Reproject and reduce grid size BEFORE
# generating contour lines to avoid publishing 0.5 m raw DEM tiles.
gdalwarp -overwrite -of GTiff \
  -t_srs EPSG:3857 -tr 20 20 -r bilinear \
  -wm 256 -wo NUM_THREADS=2 \
  -co COMPRESS=LZW -co BIGTIFF=IF_SAFER \
  "$source_file" "$raster"

echo 'Generating 20-metre contour isolines with elevation attribute...'
gdal_contour -a elevation -i 20 -f GPKG "$raster" "$contours_gpkg"

echo 'Converting contour geometries to WGS84 for Tippecanoe...'
ogr2ogr -f GeoJSON -t_srs EPSG:4326 "$contours_geojson" "$contours_gpkg"

echo 'Building vector PMTiles archive with a dedicated contours layer...'
tippecanoe -Z10 -z15 -l contours -o "$archive" "$contours_geojson"

echo 'Checking PMTiles file format and directory...'
pmtiles verify "$archive"
pmtiles show "$archive"

python3 - "$region" "$archive" "$manifest" <<'PY'
import hashlib
import json
from pathlib import Path
import sys

region, archive_path, manifest_path = sys.argv[1:]
archive = Path(archive_path)
with archive.open("rb") as f:
    magic = f.read(8)
if magic != b"PMTiles\x03":
    raise SystemExit("Invalid PMTiles v3 archive signature")

hash_value = hashlib.sha256()
with archive.open("rb") as f:
    for chunk in iter(lambda: f.read(1024 * 1024), b""):
        hash_value.update(chunk)

size = archive.stat().st_size
if size < 127 or size > 2 * 1024 * 1024 * 1024:
    raise SystemExit("Regional contour archive has invalid size")

manifest = {
    "id": f"{region}-contours",
    "parent_map_id": region,
    "tile_schema": "readysafe-contours-v1",
    "name_fr": f"{region} — Courbes de niveau 20 m",
    "name_en": f"{region} — 20 m contours",
    "country": "CH",
    "version": "pilot-1",
    "source_label": "swissALTI3D OGD, reprojected and simplified",
    "license": "swisstopo OGD - source attribution mandatory",
    "attribution": "© swisstopo",
    "byte_length": size,
    "sha256": hash_value.hexdigest(),
    "download_url": None,
    "approved": False,
    "review_required": [
        "Confirm actual swisstopo OGD source, provenance and version",
        "Confirm source is NOT the test-only sample dataset",
        "Confirm regional coverage and 20 m contour layer",
        "Inspect geographic CRS, extrema, geometry and tile metadata",
        "Test independent mobile altitude rendering in airplane mode",
        "Upload immutable PMTiles to approved HTTPS host",
    ],
}
Path(manifest_path).write_text(
    json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8",
)
print(f"Candidate: {size:,} bytes SHA-256={manifest['sha256']}")
PY

mv "$archive" "$out"
echo "Created: $out"
echo "Unapproved manifest: $manifest"
echo 'DO NOT DISTRIBUTE before source, cartographic and legal review.'
