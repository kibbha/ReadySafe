import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';
import '../services/local_storage_service.dart';

enum _PlaceKind {
  shelter,
  health,
  pharmacy,
  water,
  meeting,
  aid,
  personal,
  city,
}

class OnlineMapsScreen extends StatefulWidget {
  const OnlineMapsScreen({super.key});

  @override
  State<OnlineMapsScreen> createState() => _OnlineMapsScreenState();
}

class _OnlineMapsScreenState extends State<OnlineMapsScreen> {
  static const _style = 'https://tiles.openfreemap.org/styles/liberty';
  static const _europe = LatLng(50.0, 10.0);

  static const _countryViews = <String, CameraPosition>{
    'AL': CameraPosition(target: LatLng(41.1533, 20.1683), zoom: 6.3),
    'AD': CameraPosition(target: LatLng(42.5063, 1.5218), zoom: 10.0),
    'AM': CameraPosition(target: LatLng(40.0691, 45.0382), zoom: 6.2),
    'AT': CameraPosition(target: LatLng(47.5162, 14.5501), zoom: 6.2),
    'AZ': CameraPosition(target: LatLng(40.1431, 47.5769), zoom: 5.8),
    'BE': CameraPosition(target: LatLng(50.5039, 4.4699), zoom: 7.2),
    'BG': CameraPosition(target: LatLng(42.7339, 25.4858), zoom: 6.2),
    'BY': CameraPosition(target: LatLng(53.7098, 27.9534), zoom: 5.5),
    'BA': CameraPosition(target: LatLng(43.9159, 17.6791), zoom: 6.4),
    'CH': CameraPosition(target: LatLng(46.8182, 8.2275), zoom: 7.0),
    'CY': CameraPosition(target: LatLng(35.1264, 33.4299), zoom: 7.1),
    'CZ': CameraPosition(target: LatLng(49.8175, 15.4730), zoom: 6.4),
    'DE': CameraPosition(target: LatLng(51.1657, 10.4515), zoom: 5.5),
    'DK': CameraPosition(target: LatLng(56.2639, 9.5018), zoom: 6.2),
    'EE': CameraPosition(target: LatLng(58.5953, 25.0136), zoom: 6.3),
    'ES': CameraPosition(target: LatLng(40.4637, -3.7492), zoom: 5.4),
    'FI': CameraPosition(target: LatLng(61.9241, 25.7482), zoom: 5.1),
    'FR': CameraPosition(target: LatLng(46.2276, 2.2137), zoom: 5.4),
    'GB': CameraPosition(target: LatLng(55.3781, -3.4360), zoom: 5.2),
    'GE': CameraPosition(target: LatLng(42.3154, 43.3569), zoom: 6.1),
    'GR': CameraPosition(target: LatLng(39.0742, 21.8243), zoom: 5.9),
    'HR': CameraPosition(target: LatLng(45.1000, 15.2000), zoom: 6.0),
    'HU': CameraPosition(target: LatLng(47.1625, 19.5033), zoom: 6.4),
    'IE': CameraPosition(target: LatLng(53.4129, -8.2439), zoom: 6.2),
    'IS': CameraPosition(target: LatLng(64.9631, -19.0208), zoom: 5.5),
    'IT': CameraPosition(target: LatLng(41.8719, 12.5674), zoom: 5.3),
    'LI': CameraPosition(target: LatLng(47.1660, 9.5554), zoom: 10.0),
    'LT': CameraPosition(target: LatLng(55.1694, 23.8813), zoom: 6.2),
    'LU': CameraPosition(target: LatLng(49.8153, 6.1296), zoom: 8.3),
    'LV': CameraPosition(target: LatLng(56.8796, 24.6032), zoom: 6.2),
    'MC': CameraPosition(target: LatLng(43.7384, 7.4246), zoom: 12.0),
    'MD': CameraPosition(target: LatLng(47.4116, 28.3699), zoom: 6.4),
    'ME': CameraPosition(target: LatLng(42.7087, 19.3744), zoom: 7.1),
    'MK': CameraPosition(target: LatLng(41.6086, 21.7453), zoom: 7.0),
    'MT': CameraPosition(target: LatLng(35.9375, 14.3754), zoom: 9.0),
    'NL': CameraPosition(target: LatLng(52.1326, 5.2913), zoom: 6.6),
    'NO': CameraPosition(target: LatLng(60.4720, 8.4689), zoom: 4.8),
    'PL': CameraPosition(target: LatLng(51.9194, 19.1451), zoom: 5.7),
    'PT': CameraPosition(target: LatLng(39.3999, -8.2245), zoom: 6.0),
    'RO': CameraPosition(target: LatLng(45.9432, 24.9668), zoom: 5.8),
    'RS': CameraPosition(target: LatLng(44.0165, 21.0059), zoom: 6.2),
    'SE': CameraPosition(target: LatLng(60.1282, 18.6435), zoom: 4.9),
    'SI': CameraPosition(target: LatLng(46.1512, 14.9955), zoom: 7.1),
    'SK': CameraPosition(target: LatLng(48.6690, 19.6990), zoom: 6.5),
    'SM': CameraPosition(target: LatLng(43.9424, 12.4578), zoom: 11.0),
    'TR': CameraPosition(target: LatLng(38.9637, 35.2433), zoom: 5.2),
    'UA': CameraPosition(target: LatLng(48.3794, 31.1656), zoom: 5.0),
    'VA': CameraPosition(target: LatLng(41.9029, 12.4534), zoom: 13.0),
    'XK': CameraPosition(target: LatLng(42.6026, 20.9030), zoom: 7.2),
  };

  final _storage = LocalStorageService();
  final _search = TextEditingController();

  MapLibreMapController? _map;
  CameraPosition _camera = const CameraPosition(target: _europe, zoom: 4.3);
  String? _lastCountryCode;
  _PlaceKind? _filter;
  bool _searchOpen = false;
  final List<Circle> _circles = [];
  List<_Place> _personalPlaces = [];

  static const _places = <_Place>[
    _Place('Genève', 'Ville', 46.2044, 6.1432, _PlaceKind.city),
    _Place('Lausanne', 'Ville', 46.5197, 6.6323, _PlaceKind.city),
    _Place('Berne', 'Ville', 46.9480, 7.4474, _PlaceKind.city),
    _Place('Zurich', 'Ville', 47.3769, 8.5417, _PlaceKind.city),
    _Place('Bâle', 'Ville', 47.5596, 7.5886, _PlaceKind.city),
    _Place('Paris', 'Ville', 48.8566, 2.3522, _PlaceKind.city),
    _Place('Lyon', 'Ville', 45.7640, 4.8357, _PlaceKind.city),
    _Place('Marseille', 'Ville', 43.2965, 5.3698, _PlaceKind.city),
    _Place('Milan', 'Ville', 45.4642, 9.1900, _PlaceKind.city),
    _Place('Rome', 'Ville', 41.9028, 12.4964, _PlaceKind.city),
    _Place('Berlin', 'Ville', 52.5200, 13.4050, _PlaceKind.city),
    _Place('Munich', 'Ville', 48.1351, 11.5820, _PlaceKind.city),
    _Place('Bruxelles', 'Ville', 50.8503, 4.3517, _PlaceKind.city),
    _Place('Londres', 'Ville', 51.5074, -0.1278, _PlaceKind.city),
    _Place('Vienne', 'Ville', 48.2082, 16.3738, _PlaceKind.city),
    _Place('Madrid', 'Ville', 40.4168, -3.7038, _PlaceKind.city),
  ];

  @override
  void initState() {
    super.initState();
    _loadPersonalMarkers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final code = AppScope.of(context).activeCountry?.isoCode ?? '';
    if (_lastCountryCode == code) return;

    _lastCountryCode = code;
    _camera = _initialCamera(code);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _map?.animateCamera(
        CameraUpdate.newCameraPosition(_camera),
      );
      await _syncMarkers();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Place> get _allPlaces => [..._places, ..._personalPlaces];

  List<_Place> get _searchResults {
    final q = _search.text.trim().toLowerCase();

    if (q.isEmpty) {
      return [
        ..._personalPlaces,
        ..._places.where((place) => place.kind == _PlaceKind.city).take(8),
      ];
    }

    return _allPlaces
        .where(
          (place) =>
              '${place.name} ${place.subtitle}'.toLowerCase().contains(q),
        )
        .toList();
  }

  List<_Place> get _visibleSafetyPlaces {
    return _allPlaces.where((place) {
      if (place.kind == _PlaceKind.city) return false;
      if (_filter != null && place.kind != _filter) return false;

      final dLat = (place.lat - _camera.target.latitude).abs();
      final dLng = (place.lng - _camera.target.longitude).abs();
      return dLat < 0.35 && dLng < 0.45;
    }).toList();
  }

  Future<void> _loadPersonalMarkers() async {
    final raw = await _storage.safetyMarkers();
    final places = <_Place>[];

    for (final marker in raw) {
      final lat = marker['lat'];
      final lng = marker['lng'];

      if (lat is! num || lng is! num) continue;

      places.add(
        _Place(
          '${marker['name'] ?? 'Mon repère'}',
          '${marker['note'] ?? 'Repère personnel hors ligne'}',
          lat.toDouble(),
          lng.toDouble(),
          _kindFromName('${marker['kind'] ?? 'personal'}'),
          personal: true,
          id: '${marker['id'] ?? ''}',
        ),
      );
    }

    if (!mounted) return;
    setState(() => _personalPlaces = places);
    await _syncMarkers();
  }

  Future<void> _savePersonalMarkers() async {
    await _storage.saveSafetyMarkers([
      for (final place in _personalPlaces)
        {
          'id': place.id,
          'name': place.name,
          'note': place.subtitle,
          'lat': place.lat,
          'lng': place.lng,
          'kind': place.kind.name,
        },
    ]);
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
          circleRadius: place.personal ? 12 : 10,
          circleColor: _hex(place.kind),
          circleStrokeColor: '#ffffff',
          circleStrokeWidth: place.personal ? 4 : 3,
        ),
      );
      _circles.add(circle);
    }
  }

  Future<void> _goTo(_Place place, {double zoom = 14}) async {
    FocusScope.of(context).unfocus();

    _camera = CameraPosition(
      target: LatLng(place.lat, place.lng),
      zoom: zoom,
    );

    await _map?.animateCamera(
      CameraUpdate.newCameraPosition(_camera),
    );

    if (!mounted) return;
    setState(() => _searchOpen = false);
    await _syncMarkers();
  }

  Future<void> _setFilter(_PlaceKind? value) async {
    setState(() => _filter = value);
    await _syncMarkers();
  }

  CameraPosition _initialCamera(String code) =>
      _countryViews[code] ??
      const CameraPosition(target: _europe, zoom: 4.3);

  Future<void> _openNearby(String query) async {
    await _openExternalSearch('$query near me');
  }

  Future<void> _openExternalSearch(String query) async {
    final geo = Uri.parse(
      'geo:0,0?q=${Uri.encodeComponent(query)}',
    );

    if (await canLaunchUrl(geo)) {
      await launchUrl(
        geo,
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    final opened = await launchUrl(
      web,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      final en = Localizations.localeOf(context).languageCode == 'en';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            en
                ? 'Unable to open an external map application.'
                : 'Impossible d’ouvrir une application de cartes externe.',
          ),
        ),
      );
    }
  }

  Future<void> _copyCenterCoordinates(bool en) async {
    final text =
        '${_camera.target.latitude.toStringAsFixed(6)}, ${_camera.target.longitude.toStringAsFixed(6)}';

    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          en
              ? 'Map-center coordinates copied.'
              : 'Coordonnées du centre de la carte copiées.',
        ),
      ),
    );
  }

  Future<void> _addMarkerAtCenter() async {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final name = TextEditingController();
    final note = TextEditingController();
    var kind = _PlaceKind.personal;

    final result = await showDialog<_NewMarker>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(en ? 'Add a landmark' : 'Ajouter un repère'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: en ? 'Landmark name' : 'Nom du repère',
                    prefixIcon:
                        const Icon(Icons.edit_location_alt_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<_PlaceKind>(
                  initialValue: kind,
                  decoration: InputDecoration(
                    labelText: en ? 'Category' : 'Catégorie',
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _PlaceKind.personal,
                      child: Text(en ? 'Personal' : 'Personnel'),
                    ),
                    DropdownMenuItem(
                      value: _PlaceKind.meeting,
                      child: Text(en ? 'Meeting point' : 'Rassemblement'),
                    ),
                    DropdownMenuItem(
                      value: _PlaceKind.shelter,
                      child: Text(en ? 'Shelter / safe place' : 'Abri / lieu sûr'),
                    ),
                    DropdownMenuItem(
                      value: _PlaceKind.water,
                      child: Text(en ? 'Water' : 'Eau'),
                    ),
                    DropdownMenuItem(
                      value: _PlaceKind.health,
                      child: Text(en ? 'Health' : 'Santé'),
                    ),
                    DropdownMenuItem(
                      value: _PlaceKind.aid,
                      child: Text(en ? 'Aid / resource' : 'Aide / ressource'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => kind = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: en ? 'Note' : 'Note',
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  en
                      ? 'The landmark will be stored at the current map centre: '
                          '${_camera.target.latitude.toStringAsFixed(5)}, '
                          '${_camera.target.longitude.toStringAsFixed(5)}'
                      : 'Le repère sera placé au centre actuel de la carte : '
                          '${_camera.target.latitude.toStringAsFixed(5)}, '
                          '${_camera.target.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff65747a),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(en ? 'Cancel' : 'Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;

                Navigator.pop(
                  dialogContext,
                  _NewMarker(
                    name.text.trim(),
                    note.text.trim().isEmpty
                        ? (en
                            ? 'Offline personal landmark'
                            : 'Repère personnel hors ligne')
                        : note.text.trim(),
                    kind,
                  ),
                );
              },
              child: Text(en ? 'Add' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    note.dispose();

    if (result == null) return;

    final place = _Place(
      result.name,
      result.note,
      _camera.target.latitude,
      _camera.target.longitude,
      result.kind,
      personal: true,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    setState(
      () => _personalPlaces = [..._personalPlaces, place],
    );

    await _savePersonalMarkers();
    await _syncMarkers();
  }

  Future<void> _manageMarkers() async {
    final en = Localizations.localeOf(context).languageCode == 'en';

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark_added_outlined,
                      color: Color(0xff087f83),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      en ? 'My landmarks' : 'Mes repères',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _personalPlaces.isEmpty
                    ? Center(
                        child: Text(
                          en
                              ? 'No personal landmark saved yet.'
                              : 'Aucun repère personnel enregistré.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _personalPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _personalPlaces[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _color(place.kind).withValues(alpha: .12),
                              child: Icon(
                                _icon(place.kind),
                                color: _color(place.kind),
                              ),
                            ),
                            title: Text(
                              place.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(place.subtitle),
                            trailing: IconButton(
                              tooltip: en ? 'Delete' : 'Supprimer',
                              onPressed: () async {
                                setState(
                                  () => _personalPlaces.removeAt(index),
                                );
                                await _savePersonalMarkers();
                                await _syncMarkers();

                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                              icon:
                                  const Icon(Icons.delete_outline_rounded),
                            ),
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              await _goTo(place, zoom: 15);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayName(_Place place, bool en) {
    if (!en) return place.name;

    switch (place.name) {
      case 'Genève':
        return 'Geneva';
      case 'Berne':
        return 'Bern';
      case 'Bâle':
        return 'Basel';
      case 'Bruxelles':
        return 'Brussels';
      case 'Londres':
        return 'London';
      case 'Vienne':
        return 'Vienna';
      default:
        return place.name;
    }
  }

  String _displaySubtitle(_Place place, bool en) {
    if (place.personal) return place.subtitle;
    if (place.kind == _PlaceKind.city) {
      return en ? 'City' : 'Ville';
    }
    return place.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final places = _visibleSafetyPlaces;

    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'Map & landmarks' : 'Carte & repères'),
        actions: [
          IconButton(
            tooltip: en ? 'Copy map-center coordinates' : 'Copier les coordonnées du centre',
            onPressed: () => _copyCenterCoordinates(en),
            icon: const Icon(Icons.my_location_outlined),
          ),
          IconButton(
            tooltip: en ? 'My landmarks' : 'Mes repères',
            onPressed: _manageMarkers,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
          IconButton(
            tooltip: en
                ? 'Recenter on active country'
                : 'Recentrer sur le pays actif',
            onPressed: () async {
              final code =
                  AppScope.of(context).activeCountry?.isoCode ?? '';
              _camera = _initialCamera(code);

              await _map?.animateCamera(
                CameraUpdate.newCameraPosition(_camera),
              );
              await _syncMarkers();
            },
            icon: const Icon(Icons.center_focus_strong_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMarkerAtCenter,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(en ? 'Landmark' : 'Repère'),
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

                if (mounted) {
                  setState(() {});
                }

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
                      hintText: en
                          ? 'Search a city or saved landmark…'
                          : 'Rechercher une ville ou un repère enregistré…',
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
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 14,
                          color: Color(0x22000000),
                        ),
                      ],
                    ),
                    child: _searchResults.isEmpty
                        ? ListTile(
                            leading: const Icon(
                              Icons.open_in_new_rounded,
                              color: Color(0xff087f83),
                            ),
                            title: Text(
                              en
                                  ? 'Search in the device map app'
                                  : 'Rechercher dans l’application de cartes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(_search.text.trim()),
                            onTap: () {
                              final query = _search.text.trim();
                              if (query.isNotEmpty) {
                                _openExternalSearch(query);
                              }
                            },
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            children: _searchResults
                                .map(
                                  (place) => ListTile(
                                    dense: true,
                                    leading: Icon(
                                      _icon(place.kind),
                                      color: _color(place.kind),
                                    ),
                                    title: Text(
                                      _displayName(place, en),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _displaySubtitle(place, en),
                                    ),
                                    onTap: () => _goTo(
                                      place,
                                      zoom: place.kind == _PlaceKind.city
                                          ? 12
                                          : 14,
                                    ),
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
                      _filterChip(
                        null,
                        en ? 'All' : 'Tous',
                      ),
                      _filterChip(
                        _PlaceKind.personal,
                        en ? 'My landmarks' : 'Mes repères',
                      ),
                      _filterChip(
                        _PlaceKind.shelter,
                        en ? 'Shelters' : 'Abris',
                      ),
                      _filterChip(
                        _PlaceKind.health,
                        en ? 'Health' : 'Santé',
                      ),
                      _filterChip(
                        _PlaceKind.pharmacy,
                        en ? 'Pharmacies' : 'Pharmacies',
                      ),
                      _filterChip(
                        _PlaceKind.water,
                        en ? 'Water' : 'Eau',
                      ),
                      _filterChip(
                        _PlaceKind.meeting,
                        en ? 'Meeting' : 'Rassemblement',
                      ),
                      _filterChip(
                        _PlaceKind.aid,
                        en ? 'Aid' : 'Aide',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NearbyAction(
                        icon: Icons.local_hospital_rounded,
                        label: en ? 'Nearby hospital' : 'Hôpital proche',
                        onTap: () => _openNearby('hospital'),
                      ),
                      _NearbyAction(
                        icon: Icons.local_pharmacy_rounded,
                        label: en ? 'Pharmacy' : 'Pharmacie',
                        onTap: () => _openNearby('pharmacy'),
                      ),
                      _NearbyAction(
                        icon: Icons.emergency_rounded,
                        label: en ? 'AED' : 'DAE',
                        onTap: () => _openNearby('AED defibrillator'),
                      ),
                      _NearbyAction(
                        icon: Icons.local_police_rounded,
                        label: en ? 'Police' : 'Police',
                        onTap: () => _openNearby('police station'),
                      ),
                      _NearbyAction(
                        icon: Icons.home_work_rounded,
                        label: en ? 'Shelter' : 'Abri',
                        onTap: () => _openNearby('emergency shelter'),
                      ),
                      _NearbyAction(
                        icon: Icons.water_drop_rounded,
                        label: en ? 'Drinking water' : 'Eau potable',
                        onTap: () => _openNearby('drinking water'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_camera.target.latitude.toStringAsFixed(4)}, '
                      '${_camera.target.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff52666b),
                      ),
                    ),
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
                  tooltip: en ? 'Zoom in' : 'Zoom avant',
                  onTap: () =>
                      _map?.animateCamera(CameraUpdate.zoomBy(1)),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.remove_rounded,
                  tooltip: en ? 'Zoom out' : 'Zoom arrière',
                  onTap: () =>
                      _map?.animateCamera(CameraUpdate.zoomBy(-1)),
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
              en: en,
              displayName: (place) => _displayName(place, en),
              displaySubtitle: (place) => _displaySubtitle(place, en),
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
      case _PlaceKind.personal:
        return '#6a51a3';
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
      case _PlaceKind.personal:
        return const Color(0xff6a51a3);
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
      case _PlaceKind.personal:
        return Icons.bookmark_rounded;
      case _PlaceKind.city:
        return Icons.location_city_rounded;
    }
  }

  static _PlaceKind _kindFromName(String value) {
    for (final kind in _PlaceKind.values) {
      if (kind.name == value) return kind;
    }

    return _PlaceKind.personal;
  }
}

class _NearbySheet extends StatelessWidget {
  const _NearbySheet({
    required this.places,
    required this.onTap,
    required this.en,
    required this.displayName,
    required this.displaySubtitle,
  });

  final List<_Place> places;
  final Future<void> Function(_Place place, {double zoom}) onTap;
  final bool en;
  final String Function(_Place place) displayName;
  final String Function(_Place place) displaySubtitle;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .97),
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 188),
          child: places.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xff087f83),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          en
                              ? 'No ReadySafe personal landmark is saved around this area. Add your own important points with the “Landmark” button.'
                              : 'Aucun repère personnel ReadySafe n’est enregistré autour de cette zone. Ajoutez vos propres points importants avec le bouton « Repère ».',
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
                          Expanded(
                            child: Text(
                              en
                                  ? 'Saved landmarks'
                                  : 'Repères enregistrés',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            en
                                ? '${places.length} landmark(s)'
                                : '${places.length} repère(s)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff65747a),
                            ),
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
                              backgroundColor:
                                  _OnlineMapsScreenState._color(place.kind)
                                      .withValues(alpha: .12),
                              child: Icon(
                                _OnlineMapsScreenState._icon(place.kind),
                                size: 19,
                                color:
                                    _OnlineMapsScreenState._color(place.kind),
                              ),
                            ),
                            title: Text(
                              displayName(place),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(displaySubtitle(place)),
                            trailing: place.personal
                                ? const Icon(
                                    Icons.bookmark_rounded,
                                    color: Color(0xff6a51a3),
                                  )
                                : const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                            onTap: () => onTap(
                              place,
                              zoom: 14.5,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      );

}

class _NearbyAction extends StatelessWidget {
  const _NearbyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ActionChip(
          avatar: Icon(
            icon,
            size: 18,
            color: const Color(0xff087f83),
          ),
          label: Text(label),
          onPressed: onTap,
        ),
      );
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        elevation: 3,
        borderRadius: BorderRadius.circular(14),
        child: IconButton(
          onPressed: onTap,
          tooltip: tooltip,
          icon: Icon(icon),
        ),
      );
}

class _Place {
  const _Place(
    this.name,
    this.subtitle,
    this.lat,
    this.lng,
    this.kind, {
    this.personal = false,
    this.id = '',
  });

  final String name;
  final String subtitle;
  final double lat;
  final double lng;
  final _PlaceKind kind;
  final bool personal;
  final String id;
}

class _NewMarker {
  const _NewMarker(
    this.name,
    this.note,
    this.kind,
  );

  final String name;
  final String note;
  final _PlaceKind kind;
}
