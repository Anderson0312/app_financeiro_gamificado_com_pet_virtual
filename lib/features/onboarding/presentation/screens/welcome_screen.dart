import 'package:flutter/material.dart';

/// Tela de boas-vindas do onboarding.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.savings,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Cuidar do seu dinheiro ajuda seu pet virtual a crescer e evoluir. '
                'Registre suas finanças, atinja metas e aprenda!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Começar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
