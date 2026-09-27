import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key, required this.payload});
  final Map<String, dynamic> payload;

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  final weight = TextEditingController();
  final length = TextEditingController();
  final location = TextEditingController(text: 'Kür çayı');
  final bait = TextEditingController(text: 'qarğıdalı');
  final method = TextEditingController(text: 'olta');
  bool released = false;
  String privacy = 'private';
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final identify = widget.payload['identify'] as Map<String, dynamic>;
    final species = identify['species'] as Map<String, dynamic>;
    final confidence = (identify['confidence'] as num?)?.toDouble() ?? 0;
    final isMock = identify['is_mock'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(species['name_az']?.toString() ?? 'Nəticə')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🐟', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(species['name_az']?.toString() ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text(species['scientific_name']?.toString() ?? '', style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${Az.confidence}: ${(confidence * 100).toStringAsFixed(0)}%'),
                  LinearProgressIndicator(value: confidence.clamp(0, 1), color: AppColors.accent, backgroundColor: const Color(0xFFE0EEF2)),
                  const SizedBox(height: 8),
                  Text('${Az.habitat}: ${species['habitat']}'),
                  Text(species['description_az']?.toString() ?? ''),
                  if (isMock)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Chip(label: Text(Az.mockAi), backgroundColor: Color(0xFFFFF3CD)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(controller: weight, decoration: const InputDecoration(labelText: Az.weight), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: length, decoration: const InputDecoration(labelText: Az.length), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: location, decoration: const InputDecoration(labelText: Az.location)),
          const SizedBox(height: 8),
          TextField(controller: bait, decoration: const InputDecoration(labelText: Az.bait)),
          const SizedBox(height: 8),
          TextField(controller: method, decoration: const InputDecoration(labelText: Az.method)),
          SwitchListTile(
            title: const Text(Az.released),
            value: released,
            onChanged: (v) => setState(() => released = v),
          ),
          DropdownButtonFormField<String>(
            value: privacy,
            decoration: const InputDecoration(labelText: Az.privacy),
            items: const [
              DropdownMenuItem(value: 'private', child: Text(Az.private_)),
              DropdownMenuItem(value: 'followers', child: Text(Az.followers)),
              DropdownMenuItem(value: 'public_approx', child: Text(Az.publicApprox)),
            ],
            onChanged: (v) => setState(() => privacy = v ?? 'private'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text(Az.submitCatch),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => busy = true);
    final identify = widget.payload['identify'] as Map<String, dynamic>;
    final species = identify['species'] as Map<String, dynamic>;
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post('/api/scan/confirm', data: {
        'fish_species_id': species['id'],
        'weight_kg': double.tryParse(weight.text),
        'length_cm': double.tryParse(length.text),
        'location_name': location.text,
        'bait': bait.text,
        'fishing_method': method.text,
        'released': released,
        'privacy': privacy,
        'latitude': privacy == 'public_approx' ? 40.01 : null,
        'longitude': privacy == 'public_approx' ? 48.47 : null,
        'ai_confidence': identify['confidence'],
        'share': false,
      });
      ref.invalidate(collectionProvider);
      ref.invalidate(catchesProvider);
      ref.invalidate(albumProvider);
      ref.invalidate(achievementsProvider);
      if (!mounted) return;
      final body = res.data as Map<String, dynamic>;
      if (body['is_new_discovery'] == true) {
        context.pushReplacement('/scan/discovery', extra: body);
      } else {
        context.pushReplacement('/scan/already', extra: body);
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Xəta')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
