import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final collection = ref.watch(collectionProvider);
    final achievements = ref.watch(achievementsProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Az.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(radius: 40, backgroundColor: AppColors.softGreen, child: Text('🎣', style: TextStyle(fontSize: 36))),
          const SizedBox(height: 8),
          Text(user?['username']?.toString() ?? '', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          Text(user?['email']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          collection.when(
            data: (c) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('${c['discovered']}', 'Növ'),
                  _stat('${c['percent']}%', 'Albom'),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark),
            title: const Text(Az.collection),
            onTap: () => context.push('/collection'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(Az.catchHistory),
            onTap: () => context.push('/catches'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text(Az.recipes),
            onTap: () => context.push('/recipes'),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text(Az.tutorials),
            onTap: () => context.push('/tutorials'),
          ),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text(Az.marketplace),
            onTap: () => context.push('/marketplace'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(Az.achievements, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          achievements.when(
            data: (list) => Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: list.map((a) {
                final m = a as Map;
                final unlocked = m['unlocked'] == true;
                return Chip(
                  avatar: Text(m['icon']?.toString() ?? '🏆'),
                  label: Text(m['title_az']?.toString() ?? ''),
                  backgroundColor: unlocked ? AppColors.foam : Colors.grey.shade300,
                  side: BorderSide(color: unlocked ? AppColors.accent : Colors.grey),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepTeal)),
        Text(label, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}
