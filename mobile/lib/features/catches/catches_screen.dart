import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class CatchesScreen extends ConsumerWidget {
  const CatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catches = ref.watch(catchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.catchHistory)),
      body: catches.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(Az.emptyCatches, textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.4)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i] as Map;
                  final sp = c['species'] as Map?;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.cardShadow,
                      borderRadius: BorderRadius.circular(18),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(14)),
                          child: const Text('🎣', style: TextStyle(fontSize: 22)),
                        ),
                        title: Text(sp?['name_az']?.toString() ?? 'Balıq', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text([
                          if (c['weight_kg'] != null) '${c['weight_kg']} kq',
                          if (c['length_cm'] != null) '${c['length_cm']} sm',
                          c['location_name'] ?? '',
                        ].where((e) => e.toString().isNotEmpty).join(' · ')),
                        trailing: Text(
                          c['privacy']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
