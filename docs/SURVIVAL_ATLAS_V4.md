# ReadySafe V4 — Survival Atlas (first implementation)

Branch: `feature/survival-atlas-offline-v4`, based on `work/readysafe-v3-batch2`.
This branch deliberately does not merge into `main` and does not trigger a test APK build.

## What works now (source integrated; run Flutter tests before claiming a tested build)

- Bundled bilingual FR/EN knowledge pack at `assets/data/field_guide_v1.json`.
- 14 starter entries: 4 plants, 4 mushrooms, 6 wilderness techniques.
- Search with accent normalization, category filtering and detail steps.
- Accessible from Home > Survival encyclopedia and Kits & survival > Learn.
- Offline-first: parsing and searching these entries use `rootBundle` and do not make network requests.
- Validation: schema version, unique IDs, source URLs, required bilingual warnings/steps.
- Safety: no automatic edibility verdict, no food/medicine recommendation, explicit external mycological inspection and poison centre escalation.

**IMPORTANT:** the starter taxonomy/technique data is a draft and has **not** received botanical,
mycological or clinical expert sign-off. It must not be represented as certified guidance.
Third-party reference links are not available in airplane mode; the stored guide text is.

## Current V4 map implementation — small-area cache (Android pilot)

The Map tab now has **More > Zones hors ligne / Offline map areas**.

- It saves the **1.5 km radius around the centre of the open map** using the exact
  online MapLibre style already used in ReadySafe.
- Zoom levels **11–15** are included; areas outside the region or zoom range may be blank
  without an Internet connection.
- Users explicitly confirm the download, see its progress and received byte count,
  list saved areas with status, remove them, and tap a complete region to recenter.
- `OfflineAreaPolicy` estimates slippy tile coverage and rejects large/out-of-bounds
  areas. The map engine is capped at **3,000 tiles**, **4 simultaneous requests**,
  and identifies ReadySafe with its own User-Agent. The progress callback removes
  a download if the received byte count crosses **50 MB**.
- This is **not** the promised offline Swiss map pack, does not include guaranteed
  hiking trails/relief or offline routing, and must not be marketed as Organic Maps
  functionality yet. It is an intentionally bounded step.
- Download is intentionally **Android-only in this pilot**. MapLibre 0.26.2 on iOS
  is affected by a known custom-header/request-concurrency interaction fixed in 0.27.1.
  Any future iOS enabling must be independently verified against provider terms.
- **Validation is pending**: neither `flutter analyze` nor device airplane-mode or
  upstream networking tests have run. HTTP header application, provider download
  quotas, cache restoration after process restart and on-device storage/cleanup
  must all be verified. Do not describe this as production-ready.

## Map experience target (Organic Maps-inspired, not a fork)

1. Full offline regional vector map packs for Switzerland first (cantonal/region granularity).
2. Topographic contours, hiking footpaths, offline address/place search, landmarks, compass,
   GPS position, GPX import/export, routing entirely on device.
3. Packs downloaded on explicit user request; size/version/licence/attribution shown in advance.
4. Signed manifest containing region, version, archive URL, hash (SHA-256), byte length,
   zoom/coverage, provider and licences; atomic install, rollback and insufficient-storage handling.
5. Offline rendering through MapLibre where supported, with local PMTiles/MBTiles
   and local routing/index data. Navigation must work even when the online style URL is unreachable.
6. Maintain separate POI provenance and freshness for water sources, medical services and shelters;
   unverified coordinates must never be promoted to safety assurances.

### Blocker: current online map is NOT an offline map pack

`lib/screens/online_maps_screen.dart` still uses
`https://tiles.openfreemap.org/styles/liberty`. This is a network style, not a downloadable
Swiss dataset. Do not advertise the map tab as fully offline and do not initiate bulk tile
downloads from this endpoint.

As of 2026-11-04, OpenFreeMap's published terms allow an offline download only when
**each download is at most 3,000 tiles or 50 MB**, requests use **at most four parallel
connections**, and carry a **unique app User-Agent**. Bigger regions need provider consent.
MapLibre region caching by itself does not guarantee all these conditions; do not enable it
against the live service without verified HTTP request handling and the provider's permission.

Before shipping *regional* offline map packs: select an explicitly licensed regional dataset,
confirm attribution and redistribution rights, build a local raster/vector style referencing
the installed pack, test airplane mode including zoom/font/sprites, and validate coverage
and offline routing separately. Organic Maps is a product inspiration for feature quality,
not a source of unlicensed assets/code.

## Editorial safety pipeline (required before public launch)

- Reconcile each species against recognized local taxonomy and geographic distribution.
- Add multiple expert-reviewed identification features and genuinely licensed images,
  including toxic lookalikes, with limitations stated prominently.
- For mushrooms, do not output a positive "safe to eat" result based on photos, matching
  text, crowdsourced IDs or AI classification. Refer foraged harvests to official inspections.
- Distinguish traditional ethnobotanical use from clinically supported benefits.
  Do not publish medical preparations, dosing or treatment substitutions without
  review by qualified clinicians/pharmacists, with contraindications and interactions.
- Maintain source, review owner, revision/version, review date and expiry for each future entry.
- Use prominent offline toxicology/medical emergency advice adapted to the active country.

## Verification before APK

```sh
flutter pub get
flutter analyze
flutter test test/field_guide_test.dart
flutter test test/offline_area_policy_test.dart
flutter test
```

No Flutter SDK was available in the assistant environment when this branch was authored;
the above checks have not been executed. Do not merge or distribute an APK before tests and
on-device airplane-mode verification.

## Sources / terms to keep under review

- MapLibre offline regions: https://github.com/maplibre/flutter-maplibre-gl/blob/main/website/docs/advanced/offline-regions.md
- OpenFreeMap Terms: https://openfreemap.org/tos/
- Organic Maps: https://github.com/organicmaps/organicmaps
- Swiss food safety — mushroom foraging: https://www.blv.admin.ch/fr/champignons-comestibles
- Geneva expert mushroom inspection: https://www.ge.ch/faire-controler-champignons
- CDC safe water: https://www.cdc.gov/water-emergency/about/

- MapLibre 0.27.1 fixes iOS header throttling: https://github.com/maplibre/flutter-maplibre-gl/releases/tag/v0.27.1
