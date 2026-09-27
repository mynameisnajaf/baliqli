import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings_az.dart';
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
            ? const Center(child: Text(Az.noData))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i] as Map;
                  final sp = c['species'] as Map?;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Text('🎣')),
                      title: Text(sp?['name_az']?.toString() ?? 'Balıq'),
                      subtitle: Text([
                        if (c['weight_kg'] != null) '${c['weight_kg']} kq',
                        if (c['length_cm'] != null) '${c['length_cm']} sm',
                        c['location_name'] ?? '',
                      ].where((e) => e.toString().isNotEmpty).join(' · ')),
                      trailing: Text(c['privacy']?.toString() ?? ''),
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
