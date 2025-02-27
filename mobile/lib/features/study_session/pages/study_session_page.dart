import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_session_bloc.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/session_progress_widget.dart';
import '../widgets/session_summary_widget.dart';
import '../models/study_session.dart';

class StudySessionPage extends StatelessWidget {
  final String deckId;

  const StudySessionPage({
    Key? key,
    required this.deckId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudySessionBloc(
        studySessionService: context.read(),
        deckId: deckId,
      )..add(StudySessionStarted()),
      child: const StudySessionView(),
    );
  }
}

class StudySessionView extends StatelessWidget {
  const StudySessionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessão de Estudo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmation(context),
          ),
        ],
      ),
      body: BlocConsumer<StudySessionBloc, StudySessionState>(
        listener: (context, state) {
          if (state is StudySessionComplete) {
            _showSessionSummary(context, state.session);
          }
        },
        builder: (context, state) {
          if (state is StudySessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudySessionActive) {
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
                    child: FlashcardWidget(
                      flashcard: state.currentCard,
                      supportPhrases: state.supportPhrases,
                      showFront: !state.isCardFlipped,
                      onFlip: () => context.read<StudySessionBloc>().add(
                            StudySessionCardFlipped(),
                          ),
                      onDifficultySelected: (difficulty) {
                        context.read<StudySessionBloc>().add(
                              StudySessionDifficultySelected(difficulty),
                            );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Erro ao carregar sessão de estudo'),
          );
        },
      ),
    );
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Sessão'),
        content: const Text(
          'Tem certeza que deseja sair? Seu progresso será salvo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<StudySessionBloc>().add(StudySessionExited());
    }
  }

  void _showSessionSummary(BuildContext context, StudySession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SessionSummaryWidget(session: session),
    ).then((_) => Navigator.of(context).pop());
  }
}
