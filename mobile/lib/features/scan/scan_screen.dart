import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final picker = ImagePicker();
  bool loading = false;
  String? error;

  Future<void> _pick(ImageSource source) async {
    final x = await picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(x.path, filename: x.name),
      });
      final res = await api.dio.post('/api/scan/identify', data: form);
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>;
      context.push('/scan/result', extra: {
        'identify': data,
        'localPath': x.path,
      });
    } on DioException catch (e) {
      setState(() => error = e.response?.data?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Az.scan)),
      body: loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.deepTeal),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(Az.identifying, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Bir az gözləyin…', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.deepTeal, AppColors.waterBlue],
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, size: 64, color: Colors.white),
                        SizedBox(height: 12),
                        Text('Balıq fotosunu seçin', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('AI növü müəyyən edəcək (çəki yox)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 20),
                  _sourceCard(
                    icon: Icons.camera_alt_rounded,
                    title: Az.pickCamera,
                    subtitle: 'Canlı foto çəkin',
                    onTap: () => _pick(ImageSource.camera),
                    primary: true,
                  ),
                  const SizedBox(height: 12),
                  _sourceCard(
                    icon: Icons.photo_library_rounded,
                    title: Az.pickGallery,
                    subtitle: 'Mövcud şəkildən seçin',
                    onTap: () => _pick(ImageSource.gallery),
                    primary: false,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return Material(
      color: primary ? AppColors.deepTeal : Colors.white,
      elevation: primary ? 4 : 1,
      shadowColor: AppColors.cardShadow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary ? Colors.white.withOpacity(0.15) : AppColors.mist,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary ? Colors.white : AppColors.deepTeal, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: primary ? Colors.white : AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: primary ? Colors.white70 : AppColors.muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: primary ? Colors.white70 : AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
