import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/flashcard.dart';

class FlashcardForm extends StatefulWidget {
  final Flashcard? initialFlashcard;
  final Function(Flashcard) onSave;

  const FlashcardForm({
    super.key,
    this.initialFlashcard,
    required this.onSave,
  });

  @override
  State<FlashcardForm> createState() => _FlashcardFormState();
}

class _FlashcardFormState extends State<FlashcardForm> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFlashcard != null) {
      _wordController.text = widget.initialFlashcard!.word;
      _definitionController.text = widget.initialFlashcard!.definition;
      _exampleController.text = widget.initialFlashcard!.example ?? '';
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Flashcard(
          id: widget.initialFlashcard?.id ?? '',
          word: _wordController.text.trim(),
          definition: _definitionController.text.trim(),
          example: _exampleController.text.trim(),
          easeFactor: widget.initialFlashcard?.easeFactor ?? 2.5,
          repetitions: widget.initialFlashcard?.repetitions ?? 0,
          interval: widget.initialFlashcard?.interval ?? 0,
          successRate: widget.initialFlashcard?.successRate ?? 0.0,
          lastReviewDate: widget.initialFlashcard?.lastReviewDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initialFlashcard == null
                  ? 'Novo Cartão'
                  : 'Editar Cartão',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Palavra',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma palavra';
                }
                if (value.length > 100) {
                  return 'A palavra deve ter no máximo 100 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _definitionController,
              decoration: const InputDecoration(
                labelText: 'Definição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma definição';
                }
                if (value.length > 500) {
                  return 'A definição deve ter no máximo 500 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exampleController,
              decoration: const InputDecoration(
                labelText: 'Exemplo de Uso (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value != null && value.length > 200) {
                  return 'O exemplo deve ter no máximo 200 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    widget.initialFlashcard == null ? 'Adicionar' : 'Salvar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
