import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(marketplaceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.marketplace)),
      body: products.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text(Az.emptyMarket))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i] as Map;
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
                            color: AppColors.mist,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('🛒', style: TextStyle(fontSize: 24)),
                        ),
                        title: Text(p['name_az']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${p['seller']} · ⭐ ${p['rating']}'),
                        trailing: Text(
                          '${p['price_azn']} ${Az.azn}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepTeal),
                        ),
                        onTap: () => context.push('/marketplace/${p['id']}', extra: p),
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

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name_az']?.toString() ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('🛒', style: TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 16),
            Text('${product['price_azn']} AZN', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.deepTeal)),
            const SizedBox(height: 6),
            Text('Satıcı: ${product['seller']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Stok: ${product['stock']} · Reytinq: ${product['rating']}'),
            const SizedBox(height: 14),
            Text(product['description_az']?.toString() ?? '', style: const TextStyle(height: 1.4, color: AppColors.muted)),
            const Spacer(),
            const Text('Demo market — ödəniş yoxdur.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () {}, child: const Text('Səbətə əlavə et (demo)')),
            ),
          ],
        ),
      ),
    );
  }
}
