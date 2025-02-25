import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/presentation/features/decks/create/bloc/create_deck_bloc.dart';
import 'package:easy_reading/presentation/features/decks/create/widgets/flashcard_form.dart';
import 'package:easy_reading/domain/models/flashcard.dart';

class CreateDeckScreen extends StatelessWidget {
  const CreateDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateDeckBloc(),
      child: const CreateDeckView(),
    );
  }
}

class CreateDeckView extends StatefulWidget {
  const CreateDeckView({super.key});

  @override
  State<CreateDeckView> createState() => _CreateDeckViewState();
}

class _CreateDeckViewState extends State<CreateDeckView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FlashcardForm(
          onSave: (flashcard) {
            context.read<CreateDeckBloc>().add(AddFlashcard(flashcard));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) return;
    if (context.read<CreateDeckBloc>().state.flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um cartão ao deck'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      context.read<CreateDeckBloc>().add(
            SaveDeck(
              title: _titleController.text,
              description: _descriptionController.text,
            ),
          );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateDeckBloc, CreateDeckState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.isSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deck criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Criar Novo Deck'),
            actions: [
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveDeck,
                  tooltip: 'Salvar Deck',
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Título do Deck
                TextFormField(
                  controller: _titleController,
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
                ),

                const SizedBox(height: 16),

                // Descrição do Deck
                TextFormField(
                  controller: _descriptionController,
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
                ),

                const SizedBox(height: 24),

                // Lista de Flashcards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cartões (${state.flashcards.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: _showAddCardDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Cartão'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (state.flashcards.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum cartão adicionado',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique em "Adicionar Cartão" para começar',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = state.flashcards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(flashcard.word),
                          subtitle: Text(
                            flashcard.definition,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                      ),
                                      child: FlashcardForm(
                                        initialFlashcard: flashcard,
                                        onSave: (updatedFlashcard) {
                                          context.read<CreateDeckBloc>().add(
                                                UpdateFlashcard(
                                                  index,
                                                  updatedFlashcard,
                                                ),
                                              );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  context
                                      .read<CreateDeckBloc>()
                                      .add(RemoveFlashcard(index));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddCardDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
