import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/presentation/features/training/bloc/review_bloc.dart';
import 'package:easy_reading/presentation/features/training/widgets/flashcard_widget.dart';
import 'package:easy_reading/presentation/features/training/widgets/difficulty_buttons.dart';
import 'package:easy_reading/presentation/features/training/widgets/support_phrases_widget.dart';
import 'package:easy_reading/presentation/features/training/widgets/priority_indicator.dart';

class ReviewScreen extends StatelessWidget {
  final String deckId;

  const ReviewScreen({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(deckId: deckId)..add(StartReviewSession()),
      child: const ReviewScreenContent(),
    );
  }
}

class ReviewScreenContent extends StatelessWidget {
  const ReviewScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Erros'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // TODO: Mostrar diálogo de confirmação antes de sair
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ReviewBloc, TrainingSessionState>(
          builder: (context, state) {
            if (state.currentWord.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Cabeçalho de Revisão
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta palavra precisa de atenção extra!',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Indicador de Prioridade
                  PriorityIndicator(
                    priority: state.reviewPriority ?? 0.0,
                    repetitions: state.repetitions ?? 0,
                    nextReview: state.nextReview,
                  ),

                  const SizedBox(height: 16),

                  // Progresso
                  LinearProgressIndicator(
                    value: state.currentCardIndex / state.totalCards,
                    backgroundColor: Colors.grey[200],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Card ${state.currentCardIndex + 1} de ${state.totalCards}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Flashcard
                  Expanded(
                    child: FlashcardWidget(
                      word: state.currentWord,
                      definition: state.definition,
                      cardState: state.cardState,
                      onFlip: () {
                        context.read<ReviewBloc>().add(FlipCard());
                      },
                      isReviewMode: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Frases de Apoio
                  if (state.cardState == CardState.back) ...[
                    if (state.isLoadingPhrases)
                      const CircularProgressIndicator()
                    else
                      SupportPhrasesWidget(
                        phrases: state.supportPhrases,
                        showTip: true,
                      ),

                    const SizedBox(height: 16),

                    // Botões de Dificuldade
                    DifficultyButtons(
                      onDifficultySelected: (difficulty) {
                        context.read<ReviewBloc>().add(
                          RateCard(difficulty: difficulty),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
