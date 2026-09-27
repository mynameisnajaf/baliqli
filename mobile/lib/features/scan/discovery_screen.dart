import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, required this.catchData});
  final Map<String, dynamic> catchData;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _ctrl.forward();
    _confetti.play();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = widget.catchData['species'] as Map<String, dynamic>?;
    final unlocked = (widget.catchData['unlocked_achievements'] as List?) ?? [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepTeal, AppColors.ocean, Color(0xFF0A3D48)],
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 28,
                maxBlastForce: 24,
                minBlastForce: 8,
                emissionFrequency: 0.06,
                gravity: 0.25,
                colors: const [Colors.white, AppColors.softGreen, AppColors.accent, AppColors.rare, Color(0xFF7FDBDA)],
              ),
            ),
            SafeArea(
              child: Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _ctrl,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('✨ YENİ KƏŞF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            Az.newSpecies,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.mist,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.accent, width: 3),
                                  ),
                                  child: const Text('🐟', style: TextStyle(fontSize: 44)),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  species?['name_az']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  species?['scientific_name']?.toString() ?? '',
                                  style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  species?['habitat']?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                                if (unlocked.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.foam,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '🏆 ${unlocked.join(", ")}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: AppColors.deepTeal, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.deepTeal,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => context.go('/collection'),
                              child: const Text(Az.collection),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Ana səhifə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Paylaşım üçün Lentə keçin')),
                              );
                              context.go('/feed');
                            },
                            child: const Text(Az.share, style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlreadyCollectedScreen extends StatelessWidget {
  const AlreadyCollectedScreen({super.key, required this.catchData});
  final Map<String, dynamic> catchData;

  @override
  Widget build(BuildContext context) {
    final species = catchData['species'] as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text(Az.alreadyInCollection)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppColors.mist, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 64),
              ),
              const SizedBox(height: 16),
              Text(Az.alreadyInCollection, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(species?['name_az']?.toString() ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Ov qeydə alındı. Kolleksiya kartı artıq açıqdır.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: () => context.go('/home'), child: const Text(Az.home)),
              ),
              TextButton(onPressed: () => context.go('/feed'), child: const Text(Az.share)),
            ],
          ),
        ),
      ),
    );
  }
}
