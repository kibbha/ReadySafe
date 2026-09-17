import 'dart:convert';
import 'dart:ui' show Point;
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
  bool _showEmergency = true;
  bool _showAssembly = true;
  bool _styleReady = false;
  final _searchController = TextEditingController();

  MapPack get pack => widget.pack;

  static const _genevaPlaces = <_MapPlace>[
    _MapPlace('Genève', 'Centre-ville', 46.2044, 6.1432, Icons.location_city),
    _MapPlace('Gare Cornavin', 'Transport', 46.2102, 6.1425, Icons.train_outlined),
    _MapPlace('HUG — Hôpital', 'Urgence médicale', 46.1933, 6.1484, Icons.local_hospital_outlined, emergency: true),
    _MapPlace('Aéroport de Genève', 'Transport', 46.2381, 6.1090, Icons.flight_outlined),
    _MapPlace('Plainpalais', 'Point de rassemblement', 46.1985, 6.1427, Icons.groups_outlined, assembly: true),
    _MapPlace('Parc des Bastions', 'Point de rassemblement', 46.2003, 6.1459, Icons.groups_outlined, assembly: true),
  ];

  String get _style {
    final path = pack.localPath!;
    return jsonEncode({
      'version': 8,
      'name': 'ReadySafe Offline',
      'sources': {
        'offline': {'type': 'vector', 'url': 'pmtiles://file://$path', 'attribution': '© OpenStreetMap contributors'}
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

  Future<void> _zoom(double delta) async => _controller?.animateCamera(CameraUpdate.zoomBy(delta));

  Future<void> _goTo(_MapPlace place) async {
    FocusScope.of(context).unfocus();
    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lng), 14.5));
    if (mounted) setState(() => _searchOpen = false);
  }

  List<_MapPlace> get _results {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _genevaPlaces;
    return _genevaPlaces.where((p) => '${p.name} ${p.type}'.toLowerCase().contains(q)).toList();
  }

  Future<void> _syncPoiAnnotations() async {
    final controller = _controller;
    if (controller == null || !_styleReady || pack.countryCode != 'CH') return;
    await controller.clearCircles();
    final places = _genevaPlaces.where((p) => (p.emergency && _showEmergency) || (p.assembly && _showAssembly));
    for (final place in places) {
      await controller.addCircle(
        CircleOptions(
          geometry: LatLng(place.lat, place.lng),
          circleRadius: 9.5,
          circleColor: place.emergency ? '#d92d36' : '#087f83',
          circleStrokeColor: '#ffffff',
          circleStrokeWidth: 3,
        ),
        {'name': place.name, 'type': place.type},
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pack.localPath == null) return const Scaffold(body: Center(child: Text('Carte hors-ligne absente')));
    final title = pack.countryCode == 'CH' ? 'Suisse' : pack.countryCode;

    return Scaffold(
      appBar: AppBar(title: Text('Carte hors-ligne — $title')),
      body: Stack(children: [
        MapLibreMap(
          styleString: _style,
          initialCameraPosition: CameraPosition(target: _initialTarget, zoom: _initialZoom),
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () async {
            _styleReady = true;
            await _syncPoiAnnotations();
          },
          compassEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          myLocationEnabled: false,
          attributionButtonMargins: const Point(8, 88),
        ),
        Positioned(
          left: 12, right: 12, top: 12,
          child: Column(children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                onTap: () => setState(() => _searchOpen = true),
                onChanged: (_) => setState(() => _searchOpen = true),
                decoration: InputDecoration(
                  hintText: 'Rechercher sur la carte',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchOpen && pack.countryCode == 'CH')
              Container(
                margin: const EdgeInsets.only(top: 6),
                constraints: const BoxConstraints(maxHeight: 245),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))]),
                child: _results.isEmpty
                    ? const Padding(padding: EdgeInsets.all(18), child: Text('Aucun lieu hors-ligne correspondant'))
                    : ListView(shrinkWrap: true, padding: const EdgeInsets.symmetric(vertical: 6), children: _results.map((p) => ListTile(
                        dense: true,
                        leading: Icon(p.icon, color: p.emergency ? const Color(0xffd92d36) : const Color(0xff087f83)),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(p.type),
                        onTap: () => _goTo(p),
                      )).toList()),
              ),
          ]),
        ),
        Positioned(
          right: 12, top: 72,
          child: Column(children: [
            _MapButton(icon: Icons.layers_outlined, tooltip: 'Couches de carte', onTap: () => _showLayers(context)),
            const SizedBox(height: 8),
            _MapButton(icon: Icons.add, tooltip: 'Zoom avant', onTap: () => _zoom(1)),
            const SizedBox(height: 6),
            _MapButton(icon: Icons.remove, tooltip: 'Zoom arrière', onTap: () => _zoom(-1)),
          ]),
        ),
        Positioned(right: 12, bottom: 112, child: _MapButton(icon: Icons.my_location, tooltip: 'Recentrer', onTap: () => _controller?.animateCamera(CameraUpdate.newLatLngZoom(_initialTarget, _initialZoom)))),
        Positioned(left: 12, bottom: 106, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(7)), child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10, color: Color(0xff65747a))))),
        Positioned(
          left: 12, right: 12, bottom: 14,
          child: Card(elevation: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xffe8f5f5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.offline_pin, color: Color(0xff087f83))),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const Text('Carte disponible hors ligne', style: TextStyle(fontSize: 12, color: Color(0xff65747a)))])),
            const Icon(Icons.check_circle, color: Color(0xff087f83)),
          ])))),
        ),
      ]),
    );
  }

  Future<void> _showLayers(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => StatefulBuilder(builder: (context, modalSetState) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Couches de carte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.local_hospital_outlined, color: Color(0xffd92d36)), title: const Text('Urgences médicales'), value: _showEmergency, onChanged: (v) async { setState(() => _showEmergency = v); modalSetState(() {}); await _syncPoiAnnotations(); }),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.groups_outlined, color: Color(0xff087f83)), title: const Text('Points de rassemblement'), value: _showAssembly, onChanged: (v) async { setState(() => _showAssembly = v); modalSetState(() {}); await _syncPoiAnnotations(); }),
      ]),
    )));
  }
}

class _MapPlace {
  const _MapPlace(this.name, this.type, this.lat, this.lng, this.icon, {this.emergency = false, this.assembly = false});
  final String name, type;
  final double lat, lng;
  final IconData icon;
  final bool emergency, assembly;
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, elevation: 3, borderRadius: BorderRadius.circular(12), child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon), color: const Color(0xff172126)));
}
