import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';

final collectionProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/collection/');
  return res.data as Map<String, dynamic>;
});

final albumProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/collection/album');
  return res.data as Map<String, dynamic>;
});

final catchesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/catches/');
  return res.data as List<dynamic>;
});

final feedProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/posts/');
  return res.data as List<dynamic>;
});

final tutorialsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/tutorials/');
  return res.data as List<dynamic>;
});

final recipesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/recipes/');
  return res.data as List<dynamic>;
});

final marketplaceProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/marketplace/');
  return res.data as List<dynamic>;
});

final achievementsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/achievements/');
  return res.data as List<dynamic>;
});

final mapActivityProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/map/activity');
  return res.data as List<dynamic>;
});

final speciesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/api/fish-species/');
  return res.data as List<dynamic>;
});
