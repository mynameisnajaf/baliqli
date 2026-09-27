import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(collectionProvider);
    final catches = ref.watch(catchesProvider);
    final tutorials = ref.watch(tutorialsProvider);
    final recipes = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Az.appName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(collectionProvider);
          ref.invalidate(catchesProvider);
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => context.go('/scan'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [AppColors.deepTeal, AppColors.waterBlue]),
                    boxShadow: [BoxShadow(color: AppColors.deepTeal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Az.scanCta, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            const Text('AI ilə növü müəyyən et', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
            collection.when(
              data: (c) {
                final pct = ((c['percent'] as num?)?.toDouble() ?? 0) / 100.0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 42,
                          lineWidth: 8,
                          percent: pct.clamp(0, 1),
                          center: Text('${c['discovered']}/${c['total_species']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          progressColor: AppColors.accent,
                          backgroundColor: const Color(0xFFE0EEF2),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Az.collection, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('${c['percent']}% tamamlanıb', style: const TextStyle(color: AppColors.muted)),
                              TextButton(onPressed: () => context.push('/collection'), child: const Text('Albomu aç →')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))),
              error: (e, _) => Card(child: ListTile(title: Text('Xəta: $e'))),
            ),
            _section(context, Az.recentCatches, catches.when(
              data: (list) => list.isEmpty
                  ? const Padding(padding: EdgeInsets.all(16), child: Text(Az.noData))
                  : Column(children: list.take(5).map((c) {
                      final sp = c['species'] as Map?;
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: AppColors.softGreen.withOpacity(0.3), child: const Text('🐟')),
                        title: Text(sp?['name_az']?.toString() ?? 'Balıq'),
                        subtitle: Text(c['location_name']?.toString() ?? ''),
                        trailing: c['is_new_discovery'] == true ? const Chip(label: Text('YENİ')) : null,
                        onTap: () => context.push('/catches'),
                      );
                    }).toList()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            )),
            _section(context, Az.tutorials, tutorials.when(
              data: (list) => SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: list.take(6).map((t) => _chipCard(context, t['title_az']?.toString() ?? '', () => context.push('/tutorials'))).toList(),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            )),
            _section(context, Az.recipes, recipes.when(
              data: (list) => SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: list.take(6).map((t) => _chipCard(context, t['title_az']?.toString() ?? '', () => context.push('/recipes'))).toList(),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        child,
      ],
    );
  }

  Widget _chipCard(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD5E5EA)),
        ),
        child: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
