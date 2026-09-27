import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final cats = const ['all', 'freshwater', 'sea', 'river', 'lake', 'rare'];
  final labels = const ['Hamısı', Az.freshwater, Az.sea, Az.river, Az.lake, Az.rare];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: cats.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final album = ref.watch(albumProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Az.collection),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: album.when(
        data: (data) {
          final items = (data['items'] as List).cast<Map>();
          return TabBarView(
            controller: _tabs,
            children: cats.map((cat) {
              final filtered = cat == 'all'
                  ? items
                  : items.where((i) {
                      final sp = i['species'] as Map;
                      return sp['category'] == cat;
                    }).toList();
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final discovered = item['discovered'] == true;
                  final sp = item['species'] as Map;
                  return Container(
                    decoration: BoxDecoration(
                      color: discovered ? Colors.white : const Color(0xFF1A3340),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: discovered ? const Color(0xFFD5E5EA) : Colors.white12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(discovered ? '🐟' : '⬛', style: TextStyle(fontSize: discovered ? 40 : 36, color: discovered ? null : Colors.white24)),
                        const SizedBox(height: 8),
                        Text(
                          discovered ? sp['name_az']?.toString() ?? '' : Az.locked,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: discovered ? AppColors.ink : Colors.white54,
                          ),
                        ),
                        if (discovered)
                          Text(sp['scientific_name']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.muted)),
                        if (discovered)
                          Chip(
                            label: Text(sp['rarity']?.toString() ?? '', style: const TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppColors.foam,
                          ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
