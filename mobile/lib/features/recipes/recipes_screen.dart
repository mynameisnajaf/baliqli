import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.recipes)),
      body: recipes.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text(Az.emptyRecipes))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final r = list[i] as Map;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.cardShadow,
                      borderRadius: BorderRadius.circular(18),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('🍲', style: TextStyle(fontSize: 24)),
                        ),
                        title: Text(r['title_az']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${r['cook_time_min']} dəq · ${r['difficulty']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/recipes/${r['id']}', extra: r),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
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

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});
  final Map<String, dynamic> recipe;

  @override
  Widget build(BuildContext context) {
    final ingredients = (recipe['ingredients'] as List?) ?? [];
    final steps = (recipe['steps'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(recipe['title_az']?.toString() ?? '')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(recipe['description_az']?.toString() ?? '', style: const TextStyle(height: 1.4, color: AppColors.muted)),
          const SizedBox(height: 16),
          Text('İnqredientlər', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...ingredients.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('$e')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Addımlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.deepTeal,
                    child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${e.value}', style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
