import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_errors_bloc.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/session_progress_widget.dart';
import '../widgets/session_summary_widget.dart';
import '../models/study_session.dart';

class ReviewErrorsPage extends StatelessWidget {
  const ReviewErrorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewErrorsBloc(
        difficultCardsService: context.read(),
        studySessionService: context.read(),
      )..add(ReviewErrorsStarted()),
      child: const ReviewErrorsView(),
    );
  }
}

class ReviewErrorsView extends StatelessWidget {
  const ReviewErrorsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Palavras Difíceis'),
        actions: [
          BlocBuilder<ReviewErrorsBloc, ReviewErrorsState>(
            builder: (context, state) {
              if (state is ReviewErrorsActive) {
                return TextButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    '${state.remainingCards} restantes',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: null,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ReviewErrorsBloc, ReviewErrorsState>(
        listener: (context, state) {
          if (state is ReviewErrorsComplete) {
            _showCompletionDialog(context, state.session);
          }
        },
        builder: (context, state) {
          if (state is ReviewErrorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReviewErrorsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Parabéns!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Você não tem palavras difíceis para revisar.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar ao Início'),
                  ),
                ],
              ),
            );
          }

          if (state is ReviewErrorsActive) {
            return Column(
              children: [
                SessionProgressWidget(
                  currentCard: state.currentCardIndex + 1,
                  totalCards: state.totalCards,
                  correctAnswers: state.session.correctAnswers,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDifficultyIndicator(
                          state.currentCard.sm2Data.grade,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FlashcardWidget(
                            flashcard: state.currentCard,
                            supportPhrases: state.supportPhrases,
                            showFront: !state.isCardFlipped,
                            onFlip: () => context.read<ReviewErrorsBloc>().add(
                                  ReviewErrorsCardFlipped(),
                                ),
                            onDifficultySelected: (difficulty) {
                              context.read<ReviewErrorsBloc>().add(
                                    ReviewErrorsDifficultySelected(difficulty),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Erro ao carregar palavras difíceis'),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyIndicator(int grade) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _getDifficultyColor(grade).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getDifficultyColor(grade),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: _getDifficultyColor(grade),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getDifficultyText(grade),
            style: TextStyle(
              color: _getDifficultyColor(grade),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(int grade) {
    if (grade <= 2) return Colors.red;
    if (grade <= 3) return Colors.orange;
    return Colors.green;
  }

  String _getDifficultyText(int grade) {
    if (grade <= 2) return 'Difícil';
    if (grade <= 3) return 'Médio';
    return 'Fácil';
  }

  void _showCompletionDialog(BuildContext context, StudySession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SessionSummaryWidget(
        session: session,
      ),
    ).then((_) => Navigator.of(context).pop());
  }
}
