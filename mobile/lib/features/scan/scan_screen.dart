
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
    setState(() { loading = true; error = null; });
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
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(Az.identifying),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.deepTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.waterBlue.withOpacity(0.3), width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, size: 64, color: AppColors.deepTeal),
                        SizedBox(height: 12),
                        Text('Balıq fotosunu seçin', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('AI növü müəyyən edəcək (çəki yox)', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: AppColors.danger)),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(Az.pickCamera),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text(Az.pickGallery),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
