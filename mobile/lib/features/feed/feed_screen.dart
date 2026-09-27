import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
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
            ? const Center(child: Text('Hələ paylaşım yoxdur. Ovdan sonra paylaşın!'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(feedProvider),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i] as Map;
                    final catchData = p['catch'] as Map?;
                    final sp = catchData?['species'] as Map?;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${p['username'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(p['caption']?.toString() ?? ''),
                            if (sp != null) Text('🐟 ${sp['name_az']}', style: const TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final api = ref.read(apiClientProvider);
                                    await api.dio.post('/api/posts/${p['id']}/like');
                                    ref.invalidate(feedProvider);
                                  },
                                  icon: Icon(p['liked_by_me'] == true ? Icons.favorite : Icons.favorite_border),
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
