import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/presentation/features/decks/bloc/decks_bloc.dart';

class ImportDeckDialog extends StatefulWidget {
  final File file;

  const ImportDeckDialog({
    super.key,
    required this.file,
  });

  @override
  State<ImportDeckDialog> createState() => _ImportDeckDialogState();
}

class _ImportDeckDialogState extends State<ImportDeckDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<DecksBloc, DecksState>(
      listener: (context, state) {
        if (!state.isImporting && state.error == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deck importado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Importar Deck'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Arquivo selecionado: ${widget.file.path.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Título do Deck',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  if (value.length > 100) {
                    return 'O título deve ter no máximo 100 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  if (value.length > 500) {
                    return 'A descrição deve ter no máximo 500 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<DecksBloc, DecksState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isImporting
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          context.read<DecksBloc>().add(
                                ImportDeck(
                                  file: widget.file,
                                  title: _title,
                                  description: _description,
                                ),
                              );
                        }
                      },
                child: state.isImporting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Importar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
