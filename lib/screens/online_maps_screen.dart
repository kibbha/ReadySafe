import 'dart:ui' show Point;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class OnlineMapsScreen extends StatefulWidget {
  const OnlineMapsScreen({super.key});
  @override
  State<OnlineMapsScreen> createState() => _OnlineMapsScreenState();
}

class _OnlineMapsScreenState extends State<OnlineMapsScreen> {
  static const _style = 'https://tiles.openfreemap.org/styles/liberty';
  static const _geneva = LatLng(46.2044, 6.1432);
  MapLibreMapController? _map;
  bool _searchOpen = false;
  bool _showEmergency = true;
  bool _showAssembly = true;
  final _search = TextEditingController();
  final List<Circle> _poiCircles = [];

  static const _places = <_Place>[
    _Place('Genève', 'Ville', 46.2044, 6.1432, Icons.location_city),
    _Place('Gare Cornavin', 'Transport', 46.2102, 6.1425, Icons.train_outlined),
    _Place('HUG — Hôpital', 'Urgence médicale', 46.1933, 6.1484, Icons.local_hospital_outlined, emergency: true),
    _Place('Aéroport de Genève', 'Transport', 46.2381, 6.1090, Icons.flight_outlined),
    _Place('Plainpalais', 'Point de rassemblement', 46.1985, 6.1427, Icons.groups_outlined, assembly: true),
    _Place('Parc des Bastions', 'Point de rassemblement', 46.2003, 6.1459, Icons.groups_outlined, assembly: true),
  ];

  List<_Place> get _results {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _places;
    return _places.where((p) => '${p.name} ${p.type}'.toLowerCase().contains(q)).toList();
  }

  Future<void> _syncPois() async {
    final map = _map;
    if (map == null) return;
    for (final circle in _poiCircles) { await map.removeCircle(circle); }
    _poiCircles.clear();
    for (final p in _places) {
      if (!((p.emergency && _showEmergency) || (p.assembly && _showAssembly))) continue;
      final circle = await map.addCircle(CircleOptions(
        geometry: LatLng(p.lat, p.lng),
        circleRadius: 9,
        circleColor: p.emergency ? '#d92d36' : '#087f83',
        circleStrokeColor: '#ffffff',
        circleStrokeWidth: 3,
      ));
      _poiCircles.add(circle);
    }
  }

  Future<void> _goTo(_Place p) async {
    FocusScope.of(context).unfocus();
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(p.lat, p.lng), 15));
    if (mounted) setState(() => _searchOpen = false);
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Carte')),
    body: Stack(children: [
      MapLibreMap(
        styleString: _style,
        initialCameraPosition: const CameraPosition(target: _geneva, zoom: 11.5),
        onMapCreated: (c) => _map = c,
        onStyleLoadedCallback: _syncPois,
        compassEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: false,
        attributionButtonMargins: const Point(8, 82),
      ),
      Positioned(left: 12, right: 12, top: 12, child: Column(children: [
        Material(elevation: 3, borderRadius: BorderRadius.circular(16), child: TextField(
          controller: _search,
          onTap: () => setState(() => _searchOpen = true),
          onChanged: (_) => setState(() => _searchOpen = true),
          decoration: InputDecoration(hintText: 'Rechercher un lieu', prefixIcon: const Icon(Icons.search), suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)), border: InputBorder.none),
        )),
        if (_searchOpen) Container(
          margin: const EdgeInsets.only(top: 6), constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))]),
          child: _results.isEmpty ? const Padding(padding: EdgeInsets.all(18), child: Text('Aucun lieu correspondant')) : ListView(shrinkWrap: true, padding: const EdgeInsets.symmetric(vertical: 6), children: _results.map((p) => ListTile(dense: true, leading: Icon(p.icon, color: p.emergency ? const Color(0xffd92d36) : const Color(0xff087f83)), title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(p.type), onTap: () => _goTo(p))).toList()),
        ),
      ])),
      Positioned(right: 12, top: 74, child: Column(children: [
        _MapButton(icon: Icons.layers_outlined, tooltip: 'Couches', onTap: _layers),
        const SizedBox(height: 8),
        _MapButton(icon: Icons.add, tooltip: 'Zoom avant', onTap: () => _map?.animateCamera(CameraUpdate.zoomBy(1))),
        const SizedBox(height: 6),
        _MapButton(icon: Icons.remove, tooltip: 'Zoom arrière', onTap: () => _map?.animateCamera(CameraUpdate.zoomBy(-1))),
      ])),
      Positioned(right: 12, bottom: 24, child: _MapButton(icon: Icons.my_location, tooltip: 'Recentrer sur Genève', onTap: () => _map?.animateCamera(CameraUpdate.newLatLngZoom(_geneva, 11.5)))),
      Positioned(left: 12, bottom: 24, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(10)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.wifi, size: 16, color: Color(0xff087f83)), SizedBox(width: 6), Text('Carte en ligne', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]))),
    ]),
  );

  Future<void> _layers() async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => StatefulBuilder(builder: (ctx, modalSetState) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Couches de carte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.local_hospital_outlined, color: Color(0xffd92d36)), title: const Text('Urgences médicales'), value: _showEmergency, onChanged: (v) { setState(() => _showEmergency = v); modalSetState(() {}); _syncPois(); }),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.groups_outlined, color: Color(0xff087f83)), title: const Text('Points de rassemblement'), value: _showAssembly, onChanged: (v) { setState(() => _showAssembly = v); modalSetState(() {}); _syncPois(); }),
      ]),
    )));
  }
}

class _Place {
  const _Place(this.name, this.type, this.lat, this.lng, this.icon, {this.emergency = false, this.assembly = false});
  final String name, type; final double lat, lng; final IconData icon; final bool emergency, assembly;
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon; final String tooltip; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Material(color: Colors.white, elevation: 3, borderRadius: BorderRadius.circular(12), child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon), color: const Color(0xff172126)));
}
