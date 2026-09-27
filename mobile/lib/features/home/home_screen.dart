import 'package:cached_network_image/cached_network_image.dart';
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
      appBar: AppBar(
        title: const Text(Az.appName),
        actions: [
          IconButton(
            tooltip: Az.collection,
            onPressed: () => context.push('/collection'),
            icon: const Icon(Icons.collections_bookmark_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.deepTeal,
        onRefresh: () async {
          ref.invalidate(collectionProvider);
          ref.invalidate(catchesProvider);
          ref.invalidate(tutorialsProvider);
          ref.invalidate(recipesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                onTap: () => context.go('/scan'),
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.deepTeal, AppColors.ocean, AppColors.waterBlue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepTeal.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Az.scanCta,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'AI ilə növü müəyyən et · kolleksiyanı genişlət',
                                style: TextStyle(color: Colors.white70, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            collection.when(
              data: (c) {
                final pct = ((c['percent'] as num?)?.toDouble() ?? 0) / 100.0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 48,
                          lineWidth: 9,
                          percent: pct.clamp(0, 1),
                          animation: true,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${c['discovered']}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              Text('/${c['total_species']}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                            ],
                          ),
                          progressColor: AppColors.accent,
                          backgroundColor: AppColors.mist,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Az.collection,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text('${c['percent']}% tamamlanıb', style: const TextStyle(color: AppColors.muted)),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: () => context.push('/collection'),
                                child: const Text('Albomu aç'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
              ),
              error: (e, _) => Card(child: ListTile(title: Text('Xəta: $e'))),
            ),
            _sectionHeader(context, Az.recentCatches, onSeeAll: () => context.push('/catches')),
            catches.when(
              data: (list) => list.isEmpty
                  ? _emptyHint(Az.emptyCatches)
                  : SizedBox(
                      height: 132,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.take(8).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = list[i] as Map;
                          final sp = c['species'] as Map?;
                          final isNew = c['is_new_discovery'] == true;
                          return InkWell(
                            onTap: () => context.push('/catches'),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.mist,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text('🐟', style: TextStyle(fontSize: 20)),
                                      ),
                                      if (isNew) ...[
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.rare.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('YENİ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    sp?['name_az']?.toString() ?? 'Balıq',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    c['location_name']?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
            ),
            _sectionHeader(context, Az.tutorials, onSeeAll: () => context.push('/tutorials')),
            tutorials.when(
              data: (list) => list.isEmpty
                  ? _emptyHint(Az.emptyTutorials)
                  : SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.take(8).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final t = list[i] as Map;
                          final thumb = t['thumbnail_url']?.toString();
                          return InkWell(
                            onTap: () => context.push('/tutorials/${t['id']}', extra: t),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 96,
                                    width: double.infinity,
                                    child: thumb != null && thumb.isNotEmpty
                                        ? CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
                                        : Container(
                                            color: AppColors.mist,
                                            child: const Center(child: Icon(Icons.play_circle_outline, color: AppColors.deepTeal, size: 36)),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                    child: Text(
                                      t['title_az']?.toString() ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            _sectionHeader(context, Az.recipes, onSeeAll: () => context.push('/recipes')),
            recipes.when(
              data: (list) => list.isEmpty
                  ? _emptyHint(Az.emptyRecipes)
                  : SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.take(8).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final r = list[i] as Map;
                          return InkWell(
                            onTap: () => context.push('/recipes/${r['id']}', extra: r),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 170,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFF8EE), Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE8D9C0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🍲', style: TextStyle(fontSize: 22)),
                                  const Spacer(),
                                  Text(
                                    r['title_az']?.toString() ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Hamısı')),
        ],
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD5E5EA)),
        ),
        child: Text(text, style: const TextStyle(color: AppColors.muted, height: 1.4)),
      ),
    );
  }
}
