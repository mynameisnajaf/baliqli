import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../providers/data_providers.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.recipes)),
      body: recipes.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i] as Map;
            return Card(
              child: ListTile(
                leading: const Text('🍲', style: TextStyle(fontSize: 28)),
                title: Text(r['title_az']?.toString() ?? ''),
                subtitle: Text('${r['cook_time_min']} dəq · ${r['difficulty']}'),
                onTap: () => context.push('/recipes/${r['id']}', extra: r),
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
        padding: const EdgeInsets.all(16),
        children: [
          Text(recipe['description_az']?.toString() ?? ''),
          const SizedBox(height: 12),
          Text('İnqredientlər', style: Theme.of(context).textTheme.titleMedium),
          ...ingredients.map((e) => ListTile(dense: true, leading: const Icon(Icons.check), title: Text('$e'))),
          Text('Addımlar', style: Theme.of(context).textTheme.titleMedium),
          ...steps.asMap().entries.map((e) => ListTile(dense: true, leading: CircleAvatar(radius: 12, child: Text('${e.key + 1}')), title: Text('${e.value}'))),
        ],
      ),
    );
  }
}
