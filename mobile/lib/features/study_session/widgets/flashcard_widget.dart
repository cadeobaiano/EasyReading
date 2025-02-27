import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../flashcard/models/flashcard.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final List<String> supportPhrases;
  final bool showFront;
  final VoidCallback onFlip;
  final Function(String) onDifficultySelected;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    required this.supportPhrases,
    required this.showFront,
    required this.onFlip,
    required this.onDifficultySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      onFlip: onFlip,
      front: _buildFrontCard(context),
      back: _buildBackCard(context),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flashcard.front,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onFlip,
              child: const Text('Virar Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              flashcard.back,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: supportPhrases.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      supportPhrases[index],
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDifficultyButton(
                  context,
                  'Difícil',
                  Colors.red,
                  () => onDifficultySelected('hard'),
                ),
                _buildDifficultyButton(
                  context,
                  'Médio',
                  Colors.orange,
                  () => onDifficultySelected('medium'),
                ),
                _buildDifficultyButton(
                  context,
                  'Fácil',
                  Colors.green,
                  () => onDifficultySelected('easy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
