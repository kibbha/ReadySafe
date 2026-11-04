# ReadySafe V4 — Offline GPX tracks and waypoints

**State:** source integrated on `feature/survival-atlas-offline-v4`. Flutter analysis,
Android installation and airplane-mode verification are still pending.

## User flow

In the existing Map screen, select **More > Traces et repères GPX**.
Choose an existing `.gpx` file through the device's native file picker.
ReadySafe accepts GPX 1.0/1.1 tracks (`trk`), routes (`rte`) and named
waypoints (`wpt`). The original input file remains untouched.

- Routes/tracks persist in private application-support storage as **sanitized
  JSON**; imported XML is not stored.
- A GPX trail's original disconnected segments remain disconnected; ReadySafe
  must never draw a line across them.
- Use the visibility toggle to show/hide a trace, **Voir sur la carte** to
  recenter, and **Exporter** to share a newly created GPX document via a native
  share sheet. The user must initiate any sharing.
- Deleted traces are removed from ReadySafe's storage, not the original file.
- Imported routes and named waypoints render on the normal MapLibre map,
  including previously cached small areas.
- **More > Fond GPX sans Internet** switches to a fully local blank map
  style, preserving GPX line/point overlays with no HTTP style, sprite or tile
  request. Important: this canvas provides NO roads, trails, landmarks,
  contours or terrain. It is for orientation/reference only, not a basemap.
- Already verified local PMTiles regional map previews can also overlay
  saved GPX traces, if a compatible regional pack is later approved.

## Safety constraints

- Up to **2 MiB per input**, **12,000 trail points**, **500 waypoints**,
  **200 trail segments**, **30 stored traces** and a 4 MiB normalized file cap.
- GPX XML DOCTYPE/ENTITY declarations are rejected before parsing.
  No network source or external entity is accepted.
- Invalid coordinates (NaN, infinite, latitude outside [-90,90], longitude
  outside [-180,180]) reject the file.
- The native file picker selects just one file on an explicit user action.
  Only its content is read; the app does not scan user folders.
- All storage is local. Coordinates/tracks are **not encrypted at rest** by
  this feature and can reveal home/camp locations. User-triggered exports
  leave the app's privacy boundary.
- Rendering is limited to at most 8 visible traces, with simplification
  (up to about 1,000 vertices per route) to keep MapLibre responsive.
  **Unsimplified data remains saved/exportable.** Long segments may not show
  every intermediate bend in the preview; use the original GPX for precision.
- Never claim that a shared/imported track is safe or passable. It may
  traverse a cliff, dangerous terrain, restricted zones or a closed trail.
- GPX is a passive line/point overlay, **not offline route planning**.
- Waypoint names are unverified input. A point labeled "eau potable" does not
  establish that the water is safe to drink.

## New dependencies (compatible v11 APIs)

- `file_picker: 11.0.3`: native Android/iOS file selection. Version pinned
  using its single-file API to avoid a win32 dependency conflict with secure storage.
- `xml: ^6.6.1`: bounded GPX XML reader/writer.
- `share_plus: ^11.1.0` and `cross_file`: user-initiated native GPX export.
  Deliberately avoid share_plus 12.x build-system requirements, which exceed
  this project's Android Gradle Plugin setting.
- No geolocation plugin or cloud account is added. Existing foreground GPS
  remains manually requested only.

## Automated checks to run before Android beta

```bash
flutter pub get
flutter analyze
flutter test test/gpx_route_test.dart
flutter test
```

Unit tests are written for:
- namespaced GPX tracks, route points, segments and waypoints;
- GPX round-trip export/import without merging trail segments;
- invalid coordinates, DTD rejection and oversized XML;
- local persistence, visibility changes and deletion;
- rendering simplification retaining segment endpoints.

**These test commands have NOT been executed in the assistant's current
environment, which has no Flutter/Dart SDK.**

## Manual acceptance checklist

1. With network enabled, import a known hiking GPX (several segments,
   named waypoints, altitude); verify it draws correctly on the Map tab.
2. Turn on **Fond GPX sans Internet**, enable airplane mode, force-stop
   ReadySafe and reopen. The local GPX must remain visible.
3. Turn cellular/Wi-Fi off, leave device location enabled, and confirm
   manually requested GPS still behaves safely on a supported phone.
4. Test tapping "Show on map", hiding/showing a trace, and deleting it.
5. Export, re-import and inspect the GPX in another application, ensuring
   waypoints, segments and track names are retained.
6. Test malicious XML with DTD, malformed coordinate values, huge point
   counts and an empty GPX file. The application must refuse safely.
7. Validate line and circle overlays on Android and at least one tablet;
   measure frame rate and storage use for the 12,000-point limit.
8. Confirm no HTTP request is made while the local canvas is selected.
9. Inspect permissions: app must not request background location or broad
   user-folder access. Imported tracks must stay private until sharing.

This work prepares the planned Organic Maps-like experience, but complete
offline trail routing, elevation/contours and real licensed regional map
packs remain separate milestones.
