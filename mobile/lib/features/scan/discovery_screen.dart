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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
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
      backgroundColor: AppColors.deepTeal,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.white, AppColors.softGreen, AppColors.accent, AppColors.rare],
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
                        const Text('✨', style: TextStyle(fontSize: 56)),
                        Text(
                          Az.newSpecies,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text('🐟', style: TextStyle(fontSize: 48)),
                              Text(species?['name_az']?.toString() ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text(species?['scientific_name']?.toString() ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
                              Text(species?['habitat']?.toString() ?? '', style: const TextStyle(color: AppColors.muted)),
                              if (unlocked.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text('Nailiyyətlər: ${unlocked.join(", ")}', style: const TextStyle(color: AppColors.deepTeal)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.deepTeal),
                          onPressed: () => context.go('/collection'),
                          child: const Text(Az.collection),
                        ),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Ana səhifə', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {
                            // optional share → feed via catch
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paylaşım üçün Lentə keçin')));
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.accent, size: 72),
              const SizedBox(height: 12),
              Text(Az.alreadyInCollection, style: Theme.of(context).textTheme.headlineSmall),
              Text(species?['name_az']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Ov qeydə alındı. Kolleksiya kartı artıq açıqdır.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => context.go('/home'), child: const Text(Az.home)),
              TextButton(onPressed: () => context.go('/feed'), child: const Text(Az.share)),
            ],
          ),
        ),
      ),
    );
  }
}
