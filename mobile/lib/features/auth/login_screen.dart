import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'baliqci@test.az');
  final password = TextEditingController(text: 'secret12');
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepTeal, AppColors.waterBlue, AppColors.foam],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎣', style: TextStyle(fontSize: 48)),
                      Text(Az.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.deepTeal, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(Az.tagline, style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 24),
                      TextField(controller: email, decoration: const InputDecoration(labelText: Az.email), keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      TextField(controller: password, decoration: const InputDecoration(labelText: Az.password), obscureText: true),
                      if (auth.error != null) ...[
                        const SizedBox(height: 8),
                        Text(auth.error!, style: const TextStyle(color: AppColors.danger)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : () async {
                            setState(() => busy = true);
                            final ok = await ref.read(authProvider.notifier).login(email.text.trim(), password.text);
                            setState(() => busy = false);
                            if (ok && context.mounted) context.go('/home');
                          },
                          child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text(Az.login),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(Az.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
