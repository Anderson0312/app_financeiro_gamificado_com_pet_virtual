import 'package:flutter/material.dart';

import '../../domain/models/pet_species.dart';

/// Tela de nomeação do pet.
class PetNamingScreen extends StatefulWidget {
  const PetNamingScreen({
    super.key,
    required this.species,
    required this.onComplete,
  });

  final PetSpecies species;
  final ValueChanged<String> onComplete;

  @override
  State<PetNamingScreen> createState() => _PetNamingScreenState();
}

class _PetNamingScreenState extends State<PetNamingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nome do pet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dê um nome ao seu ${widget.species.label.toLowerCase()}!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Ex: Rex, Miau, Fofinho...',
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return 'Digite um nome';
                    if (name.length < 2) return 'Nome muito curto';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Criar meu pet!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onComplete(_nameController.text.trim());
    }
  }
}
