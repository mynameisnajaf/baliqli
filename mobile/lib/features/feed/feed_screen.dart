import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.feed)),
      body: feed.when(
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: AppColors.mist, shape: BoxShape.circle),
                        child: const Icon(Icons.dynamic_feed_outlined, size: 40, color: AppColors.deepTeal),
                      ),
                      const SizedBox(height: 16),
                      const Text(Az.emptyFeed, textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(feedProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i] as Map;
                    final catchData = p['catch'] as Map?;
                    final sp = catchData?['species'] as Map?;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.mist,
                                child: Text((p['username']?.toString().isNotEmpty == true) ? p['username'].toString()[0].toUpperCase() : '?'),
                              ),
                              const SizedBox(width: 10),
                              Text('@${p['username'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          if ((p['caption']?.toString() ?? '').isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(p['caption']?.toString() ?? '', style: const TextStyle(height: 1.35)),
                          ],
                          if (sp != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.foam,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('🐟 ${sp['name_az']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final api = ref.read(apiClientProvider);
                                  await api.dio.post('/api/posts/${p['id']}/like');
                                  ref.invalidate(feedProvider);
                                },
                                icon: Icon(
                                  p['liked_by_me'] == true ? Icons.favorite : Icons.favorite_border,
                                  color: p['liked_by_me'] == true ? AppColors.danger : null,
                                ),
                                label: Text('${p['likes_count'] ?? 0}'),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final ctrl = TextEditingController();
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(Az.comment),
                                      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Şərh yazın...')),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ləğv')),
                                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Göndər')),
                                      ],
                                    ),
                                  );
                                  if (ok == true && ctrl.text.trim().isNotEmpty) {
                                    final api = ref.read(apiClientProvider);
                                    await api.dio.post('/api/posts/${p['id']}/comments', data: {'body': ctrl.text.trim()});
                                    ref.invalidate(feedProvider);
                                  }
                                },
                                icon: const Icon(Icons.comment_outlined),
                                label: Text('${(p['comments'] as List?)?.length ?? 0}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
