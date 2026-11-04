# ReadySafe V4 — Field navigation without network

Status: code integrated, tests authored, not yet built or verified on a device.

The new **Retrouver mon repère / Find my landmark** entry is accessible from
the Home shortcuts and the existing Map > More menu. It reuses the app's
`DeviceLocationService` and `LocalStorageService.safetyMarkers()`.
It does not add an account, map service or background tracking.

## User workflow

1. Open the field navigator and tap **Actualiser ma position**.
2. Allow foreground location access if needed.
3. Tap **Enregistrer ma position** to create a named personal waypoint in local
   storage; it also appears in the existing ReadySafe personal-map markers.
4. Select an existing waypoint or one just saved.
5. Read the **straight-line** distance and true-north geographic bearing
   in degrees/cardinal directions. Tap **Actualiser ma position** again when
   needed; the screen does not silently track or upload movement.
6. Remove a saved waypoint if no longer necessary (also removes its map marker).

## Safety critical limitations

- A geographic bearing is **not** a safe walking route or a route calculation.
  The straight line may cross a cliff, gorge, river, private property,
  avalanche zone or inaccessible terrain.
- The directional arrow is **north-up**, not device-heading-aware. For actual
  field use, orient your device/map to geographic north independently.
- GPS generally does not need Internet, but a usable satellite fix is not
  guaranteed indoors, under dense cover or deep valleys.
- The position includes a displayed horizontal accuracy estimate and a
  timestamp; it must not be presented as a surveyed point.
- The app stores only waypoints the user explicitly confirms. The current
  foreground fix is held in memory and is not recorded as a track.
- Local waypoints are not encrypted by this feature. They should not be used
  to record secret addresses or other sensitive information.

## Tests

```bash
flutter analyze
flutter test test/field_navigation_test.dart
flutter test
```

The pure-Dart maths tests cover cardinal bearings, approximate WGS84
haversine distance, same-point handling, the international date line,
invalid coordinates, and the widget's local saved-markers list.

### Manual Android acceptance checks (required)

- Enable airplane mode with the phone's location services on.
- Open previously saved waypoints with all network connections disabled.
- Test GPS fix outdoors, accuracy indicator, distance and true-north bearing.
- Deny location permissions, disable device location, and confirm the
  screen handles both cases gracefully.
- Save a new point, close and reopen the app, then confirm it persists in
  the navigator and personal map markers.
- Delete the point and verify it disappears in both places.
- Test zero-distance behaviour and a location where the GPS fix fails.
- Compare with independent known geographic coordinates before any public
  release. Never represent the direct cap as an emergency-safe route.

Follow-up, separate milestones: GPX import/export, local trail graph routing,
elevation and contour packs, offline map-place search, and optional on-device
compass heading calibration (must distinguish magnetic from true north).
