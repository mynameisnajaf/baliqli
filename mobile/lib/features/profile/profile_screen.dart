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
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 3),
              ),
              child: const CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.mist,
                child: Text('🎣', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user?['username']?.toString() ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(user?['email']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          collection.when(
            data: (c) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _statCard('${c['discovered']}', 'Növ')),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard('${c['percent']}%', 'Albom')),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          _menuTile(Icons.collections_bookmark_outlined, Az.collection, () => context.push('/collection')),
          _menuTile(Icons.history, Az.catchHistory, () => context.push('/catches')),
          _menuTile(Icons.menu_book_outlined, Az.recipes, () => context.push('/recipes')),
          _menuTile(Icons.school_outlined, Az.tutorials, () => context.push('/tutorials')),
          _menuTile(Icons.storefront_outlined, Az.marketplace, () => context.push('/marketplace')),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(Az.achievements, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          achievements.when(
            data: (list) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: list.map((a) {
                  final m = a as Map;
                  final unlocked = m['unlocked'] == true;
                  return Chip(
                    avatar: Text(m['icon']?.toString() ?? '🏆'),
                    label: Text(m['title_az']?.toString() ?? ''),
                    backgroundColor: unlocked ? AppColors.foam : Colors.grey.shade200,
                    side: BorderSide(color: unlocked ? AppColors.accent : Colors.grey.shade300),
                  );
                }).toList(),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepTeal)),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: AppColors.deepTeal),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
