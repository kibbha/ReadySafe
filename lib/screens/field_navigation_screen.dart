import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/field_navigation.dart';
import '../services/device_location_service.dart';
import '../services/local_storage_service.dart';

/// GPS-only, local and manually refreshed field bearing to personal markers.
/// Never draws a road route or claims a safe straight-line walk.
class FieldNavigationScreen extends StatefulWidget {
  const FieldNavigationScreen({super.key});

  @override
  State<FieldNavigationScreen> createState() => _FieldNavigationScreenState();
}

class _FieldNavigationScreenState extends State<FieldNavigationScreen> {
  final _storage = LocalStorageService();
  final _location = const DeviceLocationService();

  List<_FieldWaypoint> _waypoints = const [];
  String? _selectedId;
  DeviceLocationResult? _position;
  DateTime? _positionAt;
  String? _error;
  bool _busy = false;

  bool get _en => Localizations.localeOf(context).languageCode == 'en';

  @override
  void initState() {
    super.initState();
    _loadWaypoints();
  }

  Future<void> _loadWaypoints() async {
    final raw = await _storage.safetyMarkers();
    final items = <_FieldWaypoint>[];
    for (final item in raw) {
      final latitude = item['lat'];
      final longitude = item['lng'];
      if (latitude is! num || longitude is! num) continue;
      final lat = latitude.toDouble();
      final lon = longitude.toDouble();
      if (!lat.isFinite || !lon.isFinite ||
          lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
      final name = (item['name']?.toString() ?? '').trim();
      final id = (item['id']?.toString() ?? '').trim();
      if (id.isEmpty || name.isEmpty) continue;
      items.add(_FieldWaypoint(
        id: id,
        name: name,
        latitude: lat,
        longitude: lon,
      ));
    }
    if (!mounted) return;
    setState(() {
      _waypoints = items;
      if (_selectedId == null ||
          !items.any((item) => item.id == _selectedId)) {
        _selectedId = items.isEmpty ? null : items.first.id;
      }
    });
  }

  Future<DeviceLocationResult?> _refreshPosition() async {
    if (_busy) return null;
    setState(() {
      _busy = true;
      _error = null;
    });
    final position = await _location.currentPosition();
    if (!mounted) return null;
    setState(() {
      _busy = false;
      _position = position.isSuccess ? position : null;
      _positionAt = position.isSuccess ? DateTime.now() : null;
      if (!position.isSuccess) {
        _error = switch (position.failure) {
          DeviceLocationFailure.servicesDisabled => _en
              ? 'Device location is disabled. Enable location services.'
              : 'Le GPS est désactivé. Activez la localisation du téléphone.',
          DeviceLocationFailure.permissionDenied => _en
              ? 'Location permission was denied.'
              : 'Autorisation de localisation refusée.',
          DeviceLocationFailure.permissionDeniedForever => _en
              ? 'Location permission is blocked. Change it in system settings.'
              : 'Localisation bloquée. Modifiez les autorisations dans les réglages.',
          _ => _en
              ? 'Position unavailable. Go to open sky and retry.'
              : 'Position indisponible. Réessayez à ciel ouvert.',
        };
      }
    });
    return position.isSuccess ? position : null;
  }

  Future<void> _saveMyPosition() async {
    final position = await _refreshPosition();
    if (!mounted || position == null) return;
    final en = _en;
    final name = TextEditingController(
      text: en ? 'My emergency landmark' : 'Mon repère de secours',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(en ? 'Save this location' : 'Enregistrer ma position'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(en
                ? 'A single waypoint will be stored on this phone. '
                  'No movement history is saved.'
                : 'Un seul repère sera conservé sur ce téléphone. '
                  'Aucun historique de déplacement n’est enregistré.'),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              controller: name,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: en ? 'Waypoint name' : 'Nom du repère',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, name.text.trim()),
            child: Text(en ? 'Save' : 'Enregistrer'),
          ),
        ],
      ),
    );
    name.dispose();
    if (!mounted || result == null || result.isEmpty) return;

    final stored = await _storage.safetyMarkers();
    final id = 'field-${DateTime.now().microsecondsSinceEpoch}';
    stored.add({
      'id': id,
      'name': result,
      'note': en ? 'Saved GPS waypoint' : 'Repère GPS enregistré',
      'lat': position.latitude!,
      'lng': position.longitude!,
      'kind': 'personal',
    });
    await _storage.saveSafetyMarkers(stored);
    await _loadWaypoints();
    if (!mounted) return;
    setState(() => _selectedId = id);
  }

  Future<void> _deleteWaypoint(_FieldWaypoint point) async {
    final en = _en;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(en ? 'Delete waypoint?' : 'Supprimer le repère ?'),
        content: Text(en
            ? 'This also removes the waypoint from the ReadySafe map.'
            : 'Ce repère sera également supprimé de la carte ReadySafe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(en ? 'Delete' : 'Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    final stored = await _storage.safetyMarkers();
    stored.removeWhere((item) => item['id']?.toString() == point.id);
    await _storage.saveSafetyMarkers(stored);
    await _loadWaypoints();
  }

  @override
  Widget build(BuildContext context) {
    final en = _en;
    final scheme = Theme.of(context).colorScheme;
    _FieldWaypoint? selected;
    for (final item in _waypoints) {
      if (item.id == _selectedId) selected = item;
    }
    NavigationLeg? leg;
    if (selected != null && _position?.isSuccess == true) {
      leg = FieldNavigation.between(
        fromLatitude: _position!.latitude!,
        fromLongitude: _position!.longitude!,
        toLatitude: selected.latitude,
        toLongitude: selected.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Navigate to a landmark' : 'Retrouver un repère')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 34),
            children: [
              Text(en ? 'YOUR OFFLINE BEARING' : 'VOTRE CAP HORS LIGNE',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900,
                  color: scheme.primary)),
              const SizedBox(height: 7),
              Text(en
                  ? 'Distance and true-north bearing between two coordinates. '
                    'The phone only requests GPS when you tap the button.'
                  : 'Distance et azimut par rapport au nord géographique, entre deux coordonnées. '
                    'Le GPS n’est interrogé que lorsque vous appuyez sur le bouton.'),
              const SizedBox(height: 10),
              Card(
                color: scheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded),
                      const SizedBox(width: 10),
                      Expanded(child: Text(en
                          ? 'A bearing is not a walkable route. It may cross cliffs, rivers, avalanche terrain or private property. '
                            'The arrow is relative to true north, NOT your phone’s current heading. '
                            'GPS may be inaccurate or unavailable.'
                          : 'Le cap n’est PAS un itinéraire praticable : il peut traverser falaises, rivières, zones d’avalanche ou propriétés privées. '
                            'La flèche se réfère au nord géographique, PAS à l’orientation du téléphone. '
                            'Le GPS peut être imprécis ou indisponible.',
                        style: TextStyle(color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : _refreshPosition,
                    icon: _busy
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded),
                    label: Text(en ? 'Refresh my GPS' : 'Actualiser ma position'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _saveMyPosition,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: Text(en ? 'Save my position' : 'Enregistrer ma position'),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
              if (_position?.isSuccess == true) ...[
                const SizedBox(height: 9),
                Text('${_position!.latitude!.toStringAsFixed(5)}, '
                    '${_position!.longitude!.toStringAsFixed(5)} '
                    '± ${_position!.accuracyMeters!.round()} m',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
                if (_positionAt != null)
                  Text(en
                      ? 'Last manual GPS fix: ${TimeOfDay.fromDateTime(_positionAt!).format(context)}'
                      : 'Dernière position GPS : ${TimeOfDay.fromDateTime(_positionAt!).format(context)}',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 20),
              Text(en ? 'Saved landmarks' : 'Repères enregistrés',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (_waypoints.isEmpty)
                Text(en ? 'No saved landmarks yet.' : 'Aucun repère enregistré.')
              else
                for (final item in _waypoints)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<String>(
                      value: item.id,
                      groupValue: _selectedId,
                      onChanged: (value) => setState(() => _selectedId = value),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${item.latitude.toStringAsFixed(5)}, '
                          '${item.longitude.toStringAsFixed(5)}'),
                      secondary: IconButton(
                        tooltip: en ? 'Delete landmark' : 'Supprimer le repère',
                        onPressed: () => _deleteWaypoint(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              if (selected != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(selected.name, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        if (leg == null)
                          Text(en
                              ? 'Tap “Refresh my GPS” to calculate bearing and distance.'
                              : 'Appuyez sur « Actualiser ma position » pour calculer le cap et la distance.',
                            textAlign: TextAlign.center)
                        else ...[
                          Transform.rotate(
                            angle: leg.bearingDegrees * math.pi / 180,
                            child: Icon(Icons.navigation_rounded,
                              size: 72, color: scheme.primary),
                          ),
                          const SizedBox(height: 10),
                          Text('${leg.bearingDegrees.round()}° ${leg.cardinal(en)}',
                            style: TextStyle(color: scheme.primary,
                              fontSize: 30, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          Text(leg.distanceLabel(en),
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 5),
                          Text(en
                              ? 'Straight-line distance · orient north before using the arrow'
                              : 'Distance à vol d’oiseau · orienter le nord avant d’utiliser la flèche',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(en
                  ? 'No automatic tracking, no data sent to a server, no online map required. '
                    'Saved landmarks are local to this device.'
                  : 'Aucun suivi automatique, aucune position envoyée à un serveur, aucune carte en ligne nécessaire. '
                    'Les repères restent sur cet appareil.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldWaypoint {
  const _FieldWaypoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id, name;
  final double latitude, longitude;
}
