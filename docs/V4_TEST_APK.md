# ReadySafe 4.0.0-dev.1+19 — Android test build

This document accompanies the first Android debug APK produced from
`feature/survival-atlas-offline-v4`. It is **not a release candidate**.

## What to test on a real Android phone/tablet

- Home > **Encyclopédie de survie**: browse 14 locally bundled trial entries,
  use search and category filters. Mushroom/plant notes are **not**
  identification clearance or safe-to-eat recommendations.
- Home > **Retrouver mon repère**: save a GPS landmark, reopen it, compare
  true-north bearing and straight-line distance. A direct bearing is NOT a
  safe hiking route, and GPS works only when the device has a fix.
- Map > More > **Traces et repères GPX**: import a small `.gpx`, show/hide
  and export it. The local **Fond GPX sans Internet** shows a blank canvas
  with GPX overlays and saved waypoints; it is NOT topographic coverage.
- Map > More > **Zones hors ligne**: save a small area around the map
  centre on Android while connected. Always verify coverage in airplane mode.
- Map > More > **Atlas régional hors ligne**: the three regional basemaps
  and three contour overlays are listed as **not available**. The secure
  downloader and local renderer exist but real licensed files are NOT
  hosted. Buttons MUST stay disabled.

## Important limitations

This build is a development preview only; never rely on it as the sole
source for emergency numbers, first aid, wilderness navigation, water
safety, foraging or avalanche decisions. Always carry independent
navigation/survival equipment and use the appropriate emergency services.

## CI build

File: `.github/workflows/readysafe-v4-test-apk.yml`

The CI runs **flutter pub get**, **flutter analyze**, **flutter test**,
and **flutter build apk --debug --split-per-abi** on the V4 branch.
It only consumes runner minutes if the commit message starts with
`ci(v4): build` or when started manually through GitHub Actions.

APK artifacts are named `ReadySafe_V4_test_APKs` and expire after
14 days. The artifact should contain split `app-arm64-v8a-debug.apk`
for most modern Android phones and tablets, along with other ABIs.

An APK should not be described as built or tested until the corresponding
CI run is successful and an artifact is confirmed.

Initial build trigger: ReadySafe V4 Android debug test, Flutter analyze and full test suite must pass.

Second CI build: file_picker migrated to the v12 single-file API to resolve win32 constraint conflicts.

Third CI build: remove share_plus win32 conflict and export through native file_picker Save As.

Fourth CI build: fix all six analyzer findings from prior run.

Fifth CI build: upgrade image to 4.12.0 and repair two isolated widget test fixtures.

Sixth CI build: align PDF 3.13.1 with image 4.12 and xml 7.0.1 to resolve Dart 3.13 archive dependency constraints.

Seventh CI build: update deprecated xml v7 GPX namespace API after resolving dependency graph.
