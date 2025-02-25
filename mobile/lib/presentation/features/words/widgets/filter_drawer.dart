import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/flashcard_filter.dart';
import 'package:easy_reading/presentation/features/words/bloc/words_portal_bloc.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordsPortalBloc, WordsPortalState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Ordenar por'),
                trailing: DropdownButton<SortBy>(
                  value: state.filter.sortBy,
                  onChanged: (SortBy? newValue) {
                    if (newValue != null) {
                      context.read<WordsPortalBloc>().add(
                            UpdateFilter(
                              state.filter.copyWith(sortBy: newValue),
                            ),
                          );
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: SortBy.word,
                      child: Text('Palavra'),
                    ),
                    DropdownMenuItem(
                      value: SortBy.lastReview,
                      child: Text('Última Revisão'),
                    ),
                    DropdownMenuItem(
                      value: SortBy.successRate,
                      child: Text('Taxa de Acerto'),
                    ),
                    DropdownMenuItem(
                      value: SortBy.difficulty,
                      child: Text('Dificuldade'),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Ordem Crescente'),
                value: state.filter.ascending,
                onChanged: (bool value) {
                  context.read<WordsPortalBloc>().add(
                        UpdateFilter(
                          state.filter.copyWith(ascending: value),
                        ),
                      );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Dificuldade'),
                trailing: DropdownButton<FilterDifficulty>(
                  value: state.filter.difficulty,
                  onChanged: (FilterDifficulty? newValue) {
                    if (newValue != null) {
                      context.read<WordsPortalBloc>().add(
                            UpdateFilter(
                              state.filter.copyWith(difficulty: newValue),
                            ),
                          );
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: FilterDifficulty.all,
                      child: Text('Todas'),
                    ),
                    DropdownMenuItem(
                      value: FilterDifficulty.easy,
                      child: Text('Fácil'),
                    ),
                    DropdownMenuItem(
                      value: FilterDifficulty.medium,
                      child: Text('Média'),
                    ),
                    DropdownMenuItem(
                      value: FilterDifficulty.hard,
                      child: Text('Difícil'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Taxa de Acerto'),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(
                        state.filter.minSuccessRate ?? 0.0,
                        state.filter.maxSuccessRate ?? 1.0,
                      ),
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      labels: RangeLabels(
                        '${((state.filter.minSuccessRate ?? 0.0) * 100).toInt()}%',
                        '${((state.filter.maxSuccessRate ?? 1.0) * 100).toInt()}%',
                      ),
                      onChanged: (RangeValues values) {
                        context.read<WordsPortalBloc>().add(
                              UpdateFilter(
                                state.filter.copyWith(
                                  minSuccessRate: values.start,
                                  maxSuccessRate: values.end,
                                ),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<WordsPortalBloc>().add(
                          UpdateFilter(const FlashcardFilter()),
                        );
                  },
                  child: const Text('Limpar Filtros'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
