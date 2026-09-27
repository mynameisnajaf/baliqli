import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings_az.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Az.register)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: Az.email)),
            const SizedBox(height: 12),
            TextField(controller: username, decoration: const InputDecoration(labelText: Az.username)),
            const SizedBox(height: 12),
            TextField(controller: password, decoration: const InputDecoration(labelText: Az.password), obscureText: true),
            if (auth.error != null) ...[
              const SizedBox(height: 8),
              Text('${auth.error}', style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : () async {
                  setState(() => busy = true);
                  final ok = await ref.read(authProvider.notifier).register(
                        email.text.trim(),
                        username.text.trim(),
                        password.text,
                      );
                  setState(() => busy = false);
                  if (ok && context.mounted) context.go('/home');
                },
                child: const Text(Az.register),
              ),
            ),
            TextButton(onPressed: () => context.go('/login'), child: const Text(Az.login)),
          ],
        ),
      ),
    );
  }
}
