import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

enum _PlaceKind { shelter, health, pharmacy, water, meeting, aid, city }

class OnlineMapsScreen extends StatefulWidget {
  const OnlineMapsScreen({super.key});

  @override
  State<OnlineMapsScreen> createState() => _OnlineMapsScreenState();
}

class _OnlineMapsScreenState extends State<OnlineMapsScreen> {
  static const _style = 'https://tiles.openfreemap.org/styles/liberty';
  static const _geneva = LatLng(46.2044, 6.1432);

  final _search = TextEditingController();
  MapLibreMapController? _map;
  CameraPosition _camera = const CameraPosition(target: _geneva, zoom: 12);
  _PlaceKind? _filter;
  bool _searchOpen = false;
  final List<Circle> _circles = [];

  static const _places = <_Place>[
    _Place('HUG — Hôpital universitaire', 'Repère santé à vérifier', 46.1933, 6.1484, _PlaceKind.health),
    _Place('Pharmacie — repère exemple', 'À vérifier avant usage', 46.2107, 6.1422, _PlaceKind.pharmacy),
    _Place('Plainpalais', 'Point de rassemblement personnel possible', 46.1985, 6.1427, _PlaceKind.meeting),
    _Place('Parc des Bastions', 'Repère de rassemblement à vérifier', 46.2003, 6.1459, _PlaceKind.meeting),
    _Place('Point d’eau — Jardin Anglais', 'Disponibilité et potabilité à vérifier', 46.2031, 6.1527, _PlaceKind.water),
    _Place('Centre sportif des Vernets', 'Repère potentiel — statut d’abri à vérifier', 46.1948, 6.1347, _PlaceKind.shelter),
    _Place('Croix-Rouge genevoise', 'Ressource locale — horaires à vérifier', 46.1990, 6.1380, _PlaceKind.aid),
    _Place('Genève', 'Ville', 46.2044, 6.1432, _PlaceKind.city),
    _Place('Gare Cornavin', 'Transport', 46.2102, 6.1425, _PlaceKind.city),
    _Place('Aéroport de Genève', 'Transport', 46.2381, 6.1090, _PlaceKind.city),
    _Place('Lausanne', 'Ville', 46.5197, 6.6323, _PlaceKind.city),
    _Place('Berne', 'Ville', 46.9480, 7.4474, _PlaceKind.city),
    _Place('Zurich', 'Ville', 47.3769, 8.5417, _PlaceKind.city),
    _Place('Paris', 'Ville', 48.8566, 2.3522, _PlaceKind.city),
    _Place('Lyon', 'Ville', 45.7640, 4.8357, _PlaceKind.city),
    _Place('Milan', 'Ville', 45.4642, 9.1900, _PlaceKind.city),
    _Place('Rome', 'Ville', 41.9028, 12.4964, _PlaceKind.city),
    _Place('Berlin', 'Ville', 52.5200, 13.4050, _PlaceKind.city),
    _Place('Bruxelles', 'Ville', 50.8503, 4.3517, _PlaceKind.city),
  ];

  List<_Place> get _searchResults {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _places.where((p) => p.kind == _PlaceKind.city).take(8).toList();
    return _places
        .where((p) => '${p.name} ${p.subtitle}'.toLowerCase().contains(q))
        .toList();
  }

  List<_Place> get _visibleSafetyPlaces {
    return _places.where((p) {
      if (p.kind == _PlaceKind.city) return false;
      if (_filter != null && p.kind != _filter) return false;
      final dLat = (p.lat - _camera.target.latitude).abs();
      final dLng = (p.lng - _camera.target.longitude).abs();
      return dLat < 0.35 && dLng < 0.45;
    }).toList();
  }

  Future<void> _syncMarkers() async {
    final map = _map;
    if (map == null) return;
    for (final circle in List<Circle>.from(_circles)) {
      await map.removeCircle(circle);
    }
    _circles.clear();

    for (final place in _visibleSafetyPlaces) {
      final circle = await map.addCircle(
        CircleOptions(
          geometry: LatLng(place.lat, place.lng),
          circleRadius: 10,
          circleColor: _hex(place.kind),
          circleStrokeColor: '#ffffff',
          circleStrokeWidth: 3,
        ),
      );
      _circles.add(circle);
    }
  }

  Future<void> _goTo(_Place place, {double zoom = 14}) async {
    FocusScope.of(context).unfocus();
    _camera = CameraPosition(target: LatLng(place.lat, place.lng), zoom: zoom);
    await _map?.animateCamera(CameraUpdate.newCameraPosition(_camera));
    if (mounted) {
      setState(() => _searchOpen = false);
      await _syncMarkers();
    }
  }

  Future<void> _setFilter(_PlaceKind? value) async {
    setState(() => _filter = value);
    await _syncMarkers();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = _visibleSafetyPlaces;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte & repères'),
        actions: [
          IconButton(
            tooltip: 'Recentrer',
            onPressed: () async {
              _camera = const CameraPosition(target: _geneva, zoom: 12);
              await _map?.animateCamera(CameraUpdate.newCameraPosition(_camera));
              await _syncMarkers();
            },
            icon: const Icon(Icons.center_focus_strong_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _style,
            initialCameraPosition: _camera,
            onMapCreated: (controller) => _map = controller,
            onStyleLoadedCallback: _syncMarkers,
            onCameraIdle: () async {
              final position = _map?.cameraPosition;
              if (position != null) {
                _camera = position;
                if (mounted) setState(() {});
                await _syncMarkers();
              }
            },
            compassEnabled: true,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: true,
            attributionButtonMargins: const Point<double>(8, 8),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(18),
                  child: TextField(
                    controller: _search,
                    onTap: () => setState(() => _searchOpen = true),
                    onChanged: (_) => setState(() => _searchOpen = true),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un lieu ou un repère…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                if (_searchOpen)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(blurRadius: 14, color: Color(0x22000000))],
                    ),
                    child: _searchResults.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Aucun résultat'),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            children: _searchResults
                                .map(
                                  (place) => ListTile(
                                    dense: true,
                                    leading: Icon(_icon(place.kind), color: _color(place.kind)),
                                    title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    subtitle: Text(place.subtitle),
                                    onTap: () => _goTo(place, zoom: place.kind == _PlaceKind.city ? 12 : 14),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(null, 'Tous'),
                      _filterChip(_PlaceKind.shelter, 'Abris'),
                      _filterChip(_PlaceKind.health, 'Santé'),
                      _filterChip(_PlaceKind.pharmacy, 'Pharmacies'),
                      _filterChip(_PlaceKind.water, 'Eau'),
                      _filterChip(_PlaceKind.meeting, 'Rassemblement'),
                      _filterChip(_PlaceKind.aid, 'Aide'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 210,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom avant',
                  onTap: () => _map?.animateCamera(CameraUpdate.zoomBy(1)),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom arrière',
                  onTap: () => _map?.animateCamera(CameraUpdate.zoomBy(-1)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: _NearbySheet(
              places: places,
              onTap: _goTo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(_PlaceKind? kind, String label) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == kind,
          showCheckmark: false,
          onSelected: (_) => _setFilter(kind),
        ),
      );

  static String _hex(_PlaceKind kind) {
    switch (kind) {
      case _PlaceKind.health:
        return '#d92d36';
      case _PlaceKind.pharmacy:
        return '#24965f';
      case _PlaceKind.water:
        return '#237fc7';
      case _PlaceKind.shelter:
        return '#087f83';
      case _PlaceKind.meeting:
        return '#147343';
      case _PlaceKind.aid:
        return '#d9822b';
      case _PlaceKind.city:
        return '#68777b';
    }
  }

  static Color _color(_PlaceKind kind) {
    switch (kind) {
      case _PlaceKind.health:
        return const Color(0xffd92d36);
      case _PlaceKind.pharmacy:
        return const Color(0xff24965f);
      case _PlaceKind.water:
        return const Color(0xff237fc7);
      case _PlaceKind.shelter:
        return const Color(0xff087f83);
      case _PlaceKind.meeting:
        return const Color(0xff147343);
      case _PlaceKind.aid:
        return const Color(0xffd9822b);
      case _PlaceKind.city:
        return const Color(0xff68777b);
    }
  }

  static IconData _icon(_PlaceKind kind) {
    switch (kind) {
      case _PlaceKind.health:
        return Icons.local_hospital_rounded;
      case _PlaceKind.pharmacy:
        return Icons.local_pharmacy_rounded;
      case _PlaceKind.water:
        return Icons.water_drop_rounded;
      case _PlaceKind.shelter:
        return Icons.home_work_rounded;
      case _PlaceKind.meeting:
        return Icons.groups_rounded;
      case _PlaceKind.aid:
        return Icons.volunteer_activism_rounded;
      case _PlaceKind.city:
        return Icons.location_city_rounded;
    }
  }
}

class _NearbySheet extends StatelessWidget {
  const _NearbySheet({required this.places, required this.onTap});

  final List<_Place> places;
  final Future<void> Function(_Place place, {double zoom}) onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .97),
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 188),
          child: places.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xff087f83)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aucun repère ReadySafe n’est enregistré autour de cette zone. La carte reste navigable et la recherche de villes est disponible.',
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 8, 5),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Repères à proximité', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        Text(
                          '${places.length} repère(s)',
                          style: const TextStyle(fontSize: 11, color: Color(0xff65747a)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 6),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return ListTile(
                          dense: true,
                          minTileHeight: 48,
                          leading: CircleAvatar(
                            radius: 17,
                            backgroundColor: _OnlineMapsScreenState._color(place.kind).withValues(alpha: .12),
                            child: Icon(
                              _OnlineMapsScreenState._icon(place.kind),
                              size: 19,
                              color: _OnlineMapsScreenState._color(place.kind),
                            ),
                          ),
                          title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(place.subtitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => onTap(place, zoom: 14.5),
                        );
                      },
                    ),
                  ),
                ],
              ),
        ),
      );
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
        borderRadius: BorderRadius.circular(14),
        child: IconButton(onPressed: onTap, tooltip: tooltip, icon: Icon(icon)),
      );
}

class _Place {
  const _Place(this.name, this.subtitle, this.lat, this.lng, this.kind);
  final String name;
  final String subtitle;
  final double lat;
  final double lng;
  final _PlaceKind kind;
}
