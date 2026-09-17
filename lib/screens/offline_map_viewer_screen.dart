import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/map_pack.dart';

class OfflineMapViewerScreen extends StatefulWidget {
  const OfflineMapViewerScreen({super.key, required this.pack});
  final MapPack pack;

  @override
  State<OfflineMapViewerScreen> createState() => _OfflineMapViewerScreenState();
}

class _OfflineMapViewerScreenState extends State<OfflineMapViewerScreen> {
  MapLibreMapController? _controller;
  bool _searchOpen = false;

  MapPack get pack => widget.pack;

  String get _style {
    final path = pack.localPath!;
    return jsonEncode({
      'version': 8,
      'name': 'ReadySafe Offline',
      'sources': {
        'offline': {
          'type': 'vector',
          'url': 'pmtiles://file://$path',
          'attribution': '© OpenStreetMap contributors',
        }
      },
      'layers': [
        {'id': 'background', 'type': 'background', 'paint': {'background-color': '#f2f4ef'}},
        {'id': 'land', 'type': 'fill', 'source': 'offline', 'source-layer': 'landuse', 'paint': {'fill-color': '#e7eee1', 'fill-opacity': 0.78}},
        {'id': 'water', 'type': 'fill', 'source': 'offline', 'source-layer': 'water', 'paint': {'fill-color': '#b9dce5'}},
        {'id': 'roads-outline', 'type': 'line', 'source': 'offline', 'source-layer': 'transportation', 'paint': {'line-color': '#b5bdb8', 'line-width': 3.0}},
        {'id': 'roads', 'type': 'line', 'source': 'offline', 'source-layer': 'transportation', 'paint': {'line-color': '#ffffff', 'line-width': 1.8}},
      ]
    });
  }

  LatLng get _initialTarget => pack.countryCode == 'CH' ? const LatLng(46.2044, 6.1432) : const LatLng(46.8, 8.2);
  double get _initialZoom => pack.countryCode == 'CH' ? 11.5 : 7.0;

  Future<void> _zoom(double delta) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.animateCamera(CameraUpdate.zoomBy(delta));
  }

  @override
  Widget build(BuildContext context) {
    if (pack.localPath == null) {
      return const Scaffold(body: Center(child: Text('Carte hors-ligne absente')));
    }
    final title = pack.countryCode == 'CH' ? 'Suisse' : pack.countryCode;
    return Scaffold(
      appBar: AppBar(title: Text('Carte hors-ligne — $title')),
      body: Stack(children: [
        MapLibreMap(
          styleString: _style,
          initialCameraPosition: CameraPosition(target: _initialTarget, zoom: _initialZoom),
          onMapCreated: (controller) => _controller = controller,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          myLocationEnabled: false,
          attributionButtonMargins: const Point(8, 88),
        ),
        Positioned(
          left: 12, right: 12, top: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _searchOpen
                ? Material(
                    key: const ValueKey('search'),
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Rechercher sur la carte',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(onPressed: () => setState(() => _searchOpen = false), icon: const Icon(Icons.close)),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : Align(
                    key: const ValueKey('button'),
                    alignment: Alignment.centerLeft,
                    child: FloatingActionButton.small(
                      heroTag: 'mapSearch',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff172126),
                      onPressed: () => setState(() => _searchOpen = true),
                      child: const Icon(Icons.search),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 12, top: 72,
          child: Column(children: [
            _MapButton(icon: Icons.layers_outlined, tooltip: 'Couches de carte', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couches hors-ligne ReadySafe')))),
            const SizedBox(height: 8),
            _MapButton(icon: Icons.add, tooltip: 'Zoom avant', onTap: () => _zoom(1)),
            const SizedBox(height: 6),
            _MapButton(icon: Icons.remove, tooltip: 'Zoom arrière', onTap: () => _zoom(-1)),
          ]),
        ),
        Positioned(
          right: 12, bottom: 112,
          child: _MapButton(icon: Icons.my_location, tooltip: 'Recentrer', onTap: () async {
            final controller = _controller;
            if (controller != null) await controller.animateCamera(CameraUpdate.newLatLngZoom(_initialTarget, _initialZoom));
          }),
        ),
        Positioned(
          left: 12, bottom: 106,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(7)),
            child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10, color: Color(0xff65747a))),
          ),
        ),
        Positioned(
          left: 12, right: 12, bottom: 14,
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xffe8f5f5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.offline_pin, color: Color(0xff087f83))),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const Text('Carte disponible hors ligne', style: TextStyle(fontSize: 12, color: Color(0xff65747a))),
                ])),
                const Icon(Icons.check_circle, color: Color(0xff087f83)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 3,
    borderRadius: BorderRadius.circular(12),
    child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon), color: const Color(0xff172126)),
  );
}
