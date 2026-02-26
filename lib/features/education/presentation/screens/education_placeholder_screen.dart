import 'package:flutter/material.dart';

/// Tela placeholder do módulo de educação financeira.
class EducationPlaceholderScreen extends StatelessWidget {
  const EducationPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educação Financeira')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Em breve',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Pílulas de conhecimento e quizzes virão aqui.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
