import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_reading/domain/models/deck.dart';
import 'package:easy_reading/presentation/features/decks/bloc/decks_bloc.dart';
import 'package:easy_reading/presentation/features/decks/widgets/deck_card.dart';
import 'package:easy_reading/presentation/features/decks/widgets/featured_deck_carousel.dart';
import 'package:easy_reading/presentation/features/decks/widgets/import_deck_dialog.dart';

class DecksTab extends StatelessWidget {
  const DecksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DecksBloc()..add(LoadDecks()),
      child: const DecksTabView(),
    );
  }
}

class DecksTabView extends StatelessWidget {
  const DecksTabView({super.key});

  Future<void> _importDeck(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => ImportDeckDialog(file: file),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DecksBloc, DecksState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<DecksBloc>().add(LoadDecks());
          },
          child: CustomScrollView(
            slivers: [
              // Barra de Ações
              SliverAppBar(
                floating: true,
                automaticallyImplyLeading: false,
                title: const Text('Decks'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateDeckScreen(),
                      ),
                    ),
                    tooltip: 'Criar Deck',
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => _importDeck(context),
                    tooltip: 'Importar Deck',
                  ),
                ],
              ),

              // Carrossel de Decks Destacados
              if (state.featuredDecks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Decks em Destaque',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        FeaturedDeckCarousel(decks: state.featuredDecks),
                      ],
                    ),
                  ),
                ),

              // Lista de Todos os Decks
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Todos os Decks',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        );
                      }
                      final deck = state.allDecks[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: DeckCard(
                          deck: deck,
                          onToggleFeatured: (isFeatured) {
                            context.read<DecksBloc>().add(
                                  ToggleFeatured(
                                    deckId: deck.id,
                                    isFeatured: isFeatured,
                                  ),
                                );
                          },
                        ),
                      );
                    },
                    childCount: state.allDecks.length + 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
