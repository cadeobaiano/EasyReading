import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/training_session_state.dart';
import 'package:easy_reading/presentation/features/training/bloc/training_bloc.dart';
import 'package:easy_reading/presentation/features/training/widgets/flashcard_widget.dart';
import 'package:easy_reading/presentation/features/training/widgets/difficulty_buttons.dart';
import 'package:easy_reading/presentation/features/training/widgets/support_phrases_widget.dart';

class TrainingScreen extends StatelessWidget {
  final String deckId;

  const TrainingScreen({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainingBloc(deckId: deckId)..add(StartTrainingSession()),
      child: const TrainingScreenContent(),
    );
  }
}

class TrainingScreenContent extends StatelessWidget {
  const TrainingScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praticar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // TODO: Mostrar diálogo de confirmação antes de sair
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingSessionState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                        context.read<TrainingBloc>().add(FlipCard());
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Frases de Apoio
                  if (state.cardState == CardState.back) ...[
                    if (state.isLoadingPhrases)
                      const CircularProgressIndicator()
                    else
                      SupportPhrasesWidget(phrases: state.supportPhrases),
                      
                    const SizedBox(height: 16),
                    
                    // Botões de Dificuldade
                    DifficultyButtons(
                      onDifficultySelected: (difficulty) {
                        context.read<TrainingBloc>().add(
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
