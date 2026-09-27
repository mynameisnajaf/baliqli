import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../providers/data_providers.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(marketplaceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.marketplace)),
      body: products.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i] as Map;
            return Card(
              child: ListTile(
                leading: const Text('🛒', style: TextStyle(fontSize: 28)),
                title: Text(p['name_az']?.toString() ?? ''),
                subtitle: Text('${p['seller']} · ⭐ ${p['rating']}'),
                trailing: Text('${p['price_azn']} ${Az.azn}', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => context.push('/marketplace/${p['id']}', extra: p),
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

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name_az']?.toString() ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product['price_azn']} AZN', style: Theme.of(context).textTheme.headlineSmall),
            Text('Satıcı: ${product['seller']}'),
            Text('Stok: ${product['stock']} · Reytinq: ${product['rating']}'),
            const SizedBox(height: 12),
            Text(product['description_az']?.toString() ?? ''),
            const Spacer(),
            const Text('Demo market — ödəniş yoxdur.', style: TextStyle(color: Colors.grey)),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('Səbətə əlavə et (demo)'))),
          ],
        ),
      ),
    );
  }
}
