import 'package:flutter/material.dart';

/// Overlay de carregamento reutilizável.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.isLoading = true});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
