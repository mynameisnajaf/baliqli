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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final discovered = item['discovered'] == true;
                  final sp = item['species'] as Map;
                  final rarity = sp['rarity']?.toString() ?? '';
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: discovered
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF132833), Color(0xFF0B1C24)],
                            ),
                      color: discovered ? Colors.white : null,
                      boxShadow: [
                        BoxShadow(
                          color: discovered ? AppColors.cardShadow : Colors.black26,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: discovered
                            ? (rarity == 'legendary' || rarity == 'rare'
                                ? AppColors.rare.withOpacity(0.5)
                                : const Color(0xFFD5E5EA))
                            : Colors.white10,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (discovered)
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.mist,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text('🐟', style: TextStyle(fontSize: 32)),
                          )
                        else
                          Opacity(
                            opacity: 0.35,
                            child: Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 32),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          discovered ? sp['name_az']?.toString() ?? '' : Az.locked,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: discovered ? AppColors.ink : Colors.white54,
                          ),
                        ),
                        if (discovered) ...[
                          const SizedBox(height: 4),
                          Text(
                            sp['scientific_name']?.toString() ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.muted),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.foam,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(rarity, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Icon(Icons.lock_outline, color: Colors.white24, size: 18),
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
