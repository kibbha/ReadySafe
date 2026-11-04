# ReadySafe — Regional offline PMTiles map packs (V4)

Implementation branch: `feature/survival-atlas-offline-v4`

## Status: architecture and in-app catalog implemented, source packs NOT approved

The Map screen offers **Atlas régional hors ligne / Regional offline atlas**.
The bundled catalog currently contains three placeholders:

- Switzerland — Lake Geneva region (`ch-leman`)
- Switzerland — Alps (`ch-alpes`)
- France — French Alps (`fr-alpes`)

All are explicitly **unavailable**. No arbitrary server URL and no hosted regional
archive is shipped yet. The code is not a replacement for Organic Maps today.

### Local data flow

1. Read `assets/data/regional_map_catalog_v1.json` (asset included in `pubspec.yaml`).
2. For a vetted entry, require `approved: true`, direct HTTPS `.pmtiles` URL,
   exact byte count, SHA-256 digest, a Protomaps-v4 tile schema, attribution
   and licence information.
3. Ask the user to authorize the download; use streaming `dart:io` HTTP and
   explicitly reject redirects, non-200 responses and mismatched content length.
4. Write under the application-support directory as `.partial`, rejecting any
   size overflow. Hash the whole file using SHA-256, then install by renaming.
5. Check **both** file size and hash when listing and opening a saved regional
   pack. A corrupt, missing or unapproved file must never be offered as ready.
6. Render with a *local* MapLibre style JSON whose only source is
   `pmtiles://file:///.../<pack>.pmtiles`.
   The preview style deliberately has no remote fonts, sprites, tiles or style
   requests. The display only shows basic vector layers from Protomaps-v4.
7. Let the user remove packs. The UI shows source and attribution.

### Why this is different from the legacy small-area MapLibre cache

- `OfflineMapAreasScreen` caches a small radius from OpenFreeMap under its
  provider-specific 3,000-tile / 50-MB / 4-request policy. It can be lost under
  cache pressure and is limited to zoom levels 11–15.
- `RegionalMapPackService` manages **complete, explicitly licensed** PMTiles
  regional files in persistent application-support storage; they are not
  assembled by bulk tile scraping from OpenFreeMap.
- The preview is **not yet** a complete walking map: contour lines, reliable
  hiking routes, labels, routing graph, offline search index and emergency
  POI verification remain separate work. GPX overlays can now be displayed
  on verified local packs, but they are not offline routing.

## Regional extract preparation (explicit operator action)

A reproducible, **not automatically executed** helper is provided at
`tools/prepare_regional_pmtiles.sh`.

1. Select a versioned **Protomaps basemap v4** PMTiles source from
   https://maps.protomaps.com/builds/ . Obtain the operator's permission
   to extract that source rather than scraping public tiled map servers.
2. Install `pmtiles` CLI from https://docs.protomaps.com/pmtiles/cli .
3. Run locally (replace the placeholder with a real immutable source):

   ```sh
   PROTOMAPS_SOURCE_URL='https://build.protomaps.com/DATE.pmtiles' \
      bash tools/prepare_regional_pmtiles.sh ch-leman
   ```

   Available identifiers: `ch-leman`, `ch-alpes`, `fr-alpes`.
   The source date, review and bbox boundaries are chosen by the operator.
   The script deliberately does not run GitHub Actions or upload anything.
4. The CLI extracts `--bbox` at `--maxzoom=15`, calls `pmtiles verify`
   and produces the exact extracted byte count plus a SHA-256 fingerprint.
5. The accompanying `.candidate.json` is **not approved**, has no
   `download_url`, and needs the full review described below.
6. Protomaps base maps **do not automatically include contour lines**.
   Verified elevation/contour datasets must be sourced and integrated
   separately with their own licence and local rendering.

Protomaps documents its global dataset as an ODbL Produced Work and requires
OpenStreetMap attribution. See https://docs.protomaps.com/basemaps/downloads .

## Requirements before enabling a regional pack

The exact archive must be legally distributable and compatible with
`tile_schema: protomaps-v4`. Verify the actual layer schema using a PMTiles
inspector, not only the `.pmtiles` extension.

For each pack:
1. Select a map extraction / hosting workflow with evidence of licences and
   the required © OpenStreetMap contributors attribution.
2. Produce an immutable, named geographic extract, not a floating `latest` URL.
3. Determine the byte size of the exact hosted artifact and compute its SHA-256.
4. Inspect coverage, layers, maximum zoom and the file header.
5. Serve the file over HTTPS with stable content length and no login requirement
   or redirect to an unreviewed host.
6. Fill `download_url`, `byte_length`, `sha256`, `license`,
   `source_label`, `attribution`, then set `approved: true`
   **only after technical and legal review**.
7. Rebuild the app with the approved manifest. Do not take untrusted remote
   manifests as authority for new download URLs.
8. Test over cellular/Wi-Fi, from a fresh install, after an app restart and in
   airplane mode. Verify every displayed layer. Re-download damaged files.
9. Check available storage, accessibility, metadata freshness, bundle size
   and deletion while testing a real medium/large regional extract.

## Tests and rollout gates

```bash
flutter pub get
flutter analyze
flutter test test/regional_map_pack_test.dart
flutter test test/offline_area_policy_test.dart
flutter test test/field_guide_test.dart
flutter test
```

Until a Flutter toolchain and Android test device are available, these tests
have **not** been run. A static code review alone is not a functional guarantee.

### Safety / privacy

- Neither cached tiles nor PMTiles proves a trail is open, safe or passable.
- Points of water are **not** automatically potable.
- Phone battery, compass, GPS reception and indoor/valley visibility are
  independent from a successful tile download.
- No background location upload or account is needed for the local preview.
- The user can remove map archives from local storage.
- Never advertise the app as a sole means of navigation in remote terrain.

### References

- MapLibre Flutter PMTiles: https://github.com/maplibre/flutter-maplibre-gl/blob/main/website/docs/advanced/pmtiles.md
- MapLibre Android PMTiles file syntax: https://maplibre.org/maplibre-native/android/examples/data/PMTiles/
- Protomaps: https://docs.protomaps.com/pmtiles/maplibre
- OpenFreeMap limitations: https://openfreemap.org/tos/
- OpenStreetMap attribution and licence: https://www.openstreetmap.org/copyright

## Hiking style and contour archives — V4 development

The local MapLibre preview now uses the **Protomaps basemap v4** source layers
(`landuse`, `landcover`, `roads`, `water`, `buildings`, `pois`) to
render distinct forest, water, main roads, footpaths/tracks and unverified
shelter/water point symbols. There are no remote fonts or sprites and **no
location labels yet**. See [TERRAIN_CONTOURS_V4.md](TERRAIN_CONTOURS_V4.md).

The catalog also contains three **separately versioned, inactive contour
archive placeholders**, one per base region. `RegionalMapPackService`
verifies the separate SHA-256, size and parent-region binding before adding
`source-layer: contours` to the entirely local style. The optional relief
archive is produced from properly licensed elevation data using
`tools/prepare_swiss_contours.sh`. No contour archive is currently hosted,
so elevation lines cannot yet be displayed on a user's device.
