import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(mapActivityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.map)),
      body: activity.when(
        data: (list) {
          final markers = list.map((a) {
            final m = a as Map;
            final isSpot = m['type'] == 'spot';
            return Marker(
              point: LatLng((m['latitude'] as num).toDouble(), (m['longitude'] as num).toDouble()),
              width: 40,
              height: 40,
              child: Tooltip(
                message: '${m['name']}${m['species_az'] != null ? ' — ${m['species_az']}' : ''}',
                child: Icon(
                  isSpot ? Icons.place : Icons.phishing,
                  color: isSpot ? AppColors.deepTeal : AppColors.accent,
                  size: 32,
                ),
              ),
            );
          }).toList();
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFFFF3CD),
                padding: const EdgeInsets.all(8),
                child: const Text('Məxfilik: ictimai ovlar təxmini koordinatla göstərilir.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(40.4, 47.8),
                    initialZoom: 6.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'az.balqici.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
