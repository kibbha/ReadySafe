import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/map_pack.dart';

class OfflineMapViewerScreen extends StatelessWidget {
  const OfflineMapViewerScreen({super.key, required this.pack});
  final MapPack pack;

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
        {
          'id': 'background',
          'type': 'background',
          'paint': {'background-color': '#eef2ed'}
        },
        {
          'id': 'land',
          'type': 'fill',
          'source': 'offline',
          'source-layer': 'landuse',
          'paint': {'fill-color': '#e8eee2', 'fill-opacity': 0.75}
        },
        {
          'id': 'water',
          'type': 'fill',
          'source': 'offline',
          'source-layer': 'water',
          'paint': {'fill-color': '#b9dce5'}
        },
        {
          'id': 'roads',
          'type': 'line',
          'source': 'offline',
          'source-layer': 'transportation',
          'paint': {'line-color': '#ffffff', 'line-width': 2.0}
        },
        {
          'id': 'roads-outline',
          'type': 'line',
          'source': 'offline',
          'source-layer': 'transportation',
          'paint': {'line-color': '#b5bdb8', 'line-width': 0.7}
        }
      ]
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pack.localPath == null) {
      return const Scaffold(body: Center(child: Text('Carte hors-ligne absente')));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Carte hors-ligne — ${pack.countryCode}')),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _style,
            initialCameraPosition: const CameraPosition(
              target: LatLng(46.8, 8.2),
              zoom: 7.0,
            ),
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: false,
            myLocationEnabled: false,
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.offline_pin, color: Color(0xff087f83)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pack.countryCode, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const Text('Carte disponible hors ligne', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const Text('© OSM', style: TextStyle(fontSize: 11, color: Color(0xff65747a))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
