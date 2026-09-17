import 'package:flutter/widgets.dart';

abstract interface class OfflineMapViewportController {
  void zoomIn();
  void zoomOut();
  void moveBy({
    required double horizontalPixels,
    required double verticalPixels,
  });
  Future<void> centerOnUser();
}

class OfflineMapView {
  const OfflineMapView({required this.widget, required this.controller});
  final Widget widget;
  final OfflineMapViewportController controller;
}

/// Rendering boundary for a future MapLibre/PMTiles adapter. Implementations
/// must render exclusively from [localPackPath], support zoom/pan and optional
/// GPS centering, and never fall back to network styles or tile URLs.
abstract interface class OfflineMapRenderer {
  OfflineMapView buildMap({
    required String localPackPath,
    required bool locationEnabled,
  });
}

class UnconfiguredOfflineMapRenderer implements OfflineMapRenderer {
  const UnconfiguredOfflineMapRenderer();
  @override
  OfflineMapView buildMap({
    required String localPackPath,
    required bool locationEnabled,
  }) => throw StateError('No offline map rendering adapter configured');
}
