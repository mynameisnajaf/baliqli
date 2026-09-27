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
  void dispose() {
    weight.dispose();
    length.dispose();
    location.dispose();
    bait.dispose();
    method.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identify = widget.payload['identify'] as Map<String, dynamic>;
    final species = identify['species'] as Map<String, dynamic>;
    final confidence = (identify['confidence'] as num?)?.toDouble() ?? 0;
    final isMock = identify['is_mock'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(species['name_az']?.toString() ?? 'Nəticə')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.mist,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text('🐟', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              species['name_az']?.toString() ?? '',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              species['scientific_name']?.toString() ?? '',
                              style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('${Az.confidence}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${(confidence * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepTeal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: confidence.clamp(0, 1),
                      minHeight: 8,
                      color: AppColors.accent,
                      backgroundColor: AppColors.mist,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('${Az.habitat}: ${species['habitat']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(species['description_az']?.toString() ?? '', style: const TextStyle(color: AppColors.muted, height: 1.35)),
                  if (isMock)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Chip(label: Text(Az.mockAi), backgroundColor: Color(0xFFFFF3CD)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ov detalları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(controller: weight, decoration: const InputDecoration(labelText: Az.weight), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(controller: length, decoration: const InputDecoration(labelText: Az.length), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(controller: location, decoration: const InputDecoration(labelText: Az.location)),
          const SizedBox(height: 10),
          TextField(controller: bait, decoration: const InputDecoration(labelText: Az.bait)),
          const SizedBox(height: 10),
          TextField(controller: method, decoration: const InputDecoration(labelText: Az.method)),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(Az.released),
            value: released,
            activeColor: AppColors.accent,
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
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text(Az.submitCatch),
            ),
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
