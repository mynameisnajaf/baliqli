import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';

String? youtubeIdFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  return uri.queryParameters['v'];
}

String? categoryLabel(String? cat) {
  switch (cat) {
    case 'fishing':
      return 'Ov';
    case 'equipment':
      return 'Avadanlıq';
    case 'handling':
      return 'Davranış';
    default:
      return cat;
  }
}

class TutorialsScreen extends ConsumerWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorials = ref.watch(tutorialsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.tutorials)),
      body: tutorials.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text(Az.emptyTutorials))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final t = list[i] as Map;
                  final thumb = t['thumbnail_url']?.toString();
                  final completed = t['completed'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.cardShadow,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.push('/tutorials/${t['id']}', extra: t),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (thumb != null && thumb.isNotEmpty)
                                      CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
                                    else
                                      Container(color: AppColors.mist),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.05),
                                            Colors.black.withOpacity(0.45),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 56),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${t['duration_min']} dəq',
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    if (completed)
                                      const Positioned(
                                        left: 10,
                                        top: 10,
                                        child: Icon(Icons.check_circle, color: AppColors.accent, size: 28),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['title_az']?.toString() ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      Chip(
                                        label: Text(categoryLabel(t['category']?.toString()) ?? ''),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Chip(
                                        label: Text(t['difficulty']?.toString() ?? ''),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

class TutorialDetailScreen extends ConsumerWidget {
  const TutorialDetailScreen({super.key, required this.tutorial});
  final Map<String, dynamic> tutorial;

  Future<void> _openYoutube(BuildContext context) async {
    final url = tutorial['video_url']?.toString();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video linki yoxdur')));
      return;
    }
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('YouTube açıla bilmədi')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumb = tutorial['thumbnail_url']?.toString();
    final videoUrl = tutorial['video_url']?.toString();
    final ytId = youtubeIdFromUrl(videoUrl);

    return Scaffold(
      appBar: AppBar(title: Text(tutorial['title_az']?.toString() ?? Az.tutorials)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
                  else if (ytId != null)
                    CachedNetworkImage(
                      imageUrl: 'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: AppColors.mist),
                  Container(color: Colors.black26),
                  Center(
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.deepTeal,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () => _openYoutube(context),
                      icon: const Icon(Icons.play_arrow_rounded, size: 36),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tutorial['description_az']?.toString() ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(categoryLabel(tutorial['category']?.toString()) ?? '')),
              Chip(label: Text('${tutorial['duration_min']} dəq')),
              Chip(label: Text(tutorial['difficulty']?.toString() ?? '')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openYoutube(context),
              icon: const Icon(Icons.ondemand_video_rounded),
              label: const Text(Az.watchOnYoutube),
            ),
          ),
          if (videoUrl != null && videoUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(videoUrl, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          Text('Qısa məsləhətlər', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD5E5EA)),
            ),
            child: Text(
              tutorial['content_md']?.toString() ?? '',
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
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
