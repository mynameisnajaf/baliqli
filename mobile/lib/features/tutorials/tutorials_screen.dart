import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
import '../../providers/data_providers.dart';

class TutorialsScreen extends ConsumerWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorials = ref.watch(tutorialsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.tutorials)),
      body: tutorials.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final t = list[i] as Map;
            return Card(
              child: ListTile(
                leading: Icon(t['completed'] == true ? Icons.check_circle : Icons.school_outlined),
                title: Text(t['title_az']?.toString() ?? ''),
                subtitle: Text('${t['duration_min']} dəq · ${t['category']} · ${t['difficulty']}'),
                onTap: () => context.push('/tutorials/${t['id']}', extra: t),
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

class TutorialDetailScreen extends ConsumerWidget {
  const TutorialDetailScreen({super.key, required this.tutorial});
  final Map<String, dynamic> tutorial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(tutorial['title_az']?.toString() ?? '')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tutorial['description_az']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(tutorial['content_md']?.toString() ?? ''),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final api = ref.read(apiClientProvider);
              await api.dio.post('/api/tutorials/${tutorial['id']}/complete');
              ref.invalidate(tutorialsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tamamlandı!')));
              }
            },
            child: const Text(Az.markComplete),
          ),
        ],
      ),
    );
  }
}
