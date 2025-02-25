import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/flashcard_filter.dart';
import 'package:easy_reading/presentation/features/words/bloc/words_portal_bloc.dart';
import 'package:easy_reading/presentation/features/words/widgets/filter_drawer.dart';
import 'package:easy_reading/presentation/features/words/widgets/flashcard_list_item.dart';
import 'package:easy_reading/presentation/features/words/widgets/search_bar_widget.dart';

class WordsPortalScreen extends StatelessWidget {
  const WordsPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordsPortalBloc()..add(LoadFlashcards()),
      child: const WordsPortalView(),
    );
  }
}

class WordsPortalView extends StatelessWidget {
  const WordsPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palavras Treinadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const FilterDrawer(),
      body: BlocBuilder<WordsPortalBloc, WordsPortalState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WordsPortalBloc>().add(LoadFlashcards());
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Barra de Pesquisa
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBarWidget(
                  onSearch: (query) {
                    context.read<WordsPortalBloc>().add(
                      UpdateFilter(
                        state.filter.copyWith(searchQuery: query),
                      ),
                    );
                  },
                ),
              ),

              // Estatísticas Rápidas
              if (state.flashcards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatisticChip(
                        label: 'Total',
                        value: state.flashcards.length.toString(),
                        icon: Icons.format_list_numbered,
                      ),
                      _StatisticChip(
                        label: 'Dominadas',
                        value: state.masteredCount.toString(),
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                      _StatisticChip(
                        label: 'Taxa de Acerto',
                        value: '${(state.averageSuccessRate * 100).toInt()}%',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),

              // Lista de Flashcards
              Expanded(
                child: state.flashcards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma palavra encontrada',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (state.filter.searchQuery.isNotEmpty ||
                                state.filter.difficulty != FilterDifficulty.all)
                              TextButton(
                                onPressed: () {
                                  context.read<WordsPortalBloc>().add(
                                    UpdateFilter(
                                      const FlashcardFilter(),
                                    ),
                                  );
                                },
                                child: const Text('Limpar Filtros'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: state.flashcards.length,
                        itemBuilder: (context, index) {
                          final flashcard = state.flashcards[index];
                          return FlashcardListItem(
                            flashcard: flashcard,
                            onTap: () {
                              // TODO: Navegar para detalhes do flashcard
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatisticChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatisticChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
