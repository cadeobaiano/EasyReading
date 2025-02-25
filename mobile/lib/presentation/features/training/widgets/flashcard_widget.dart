import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/training_session_state.dart';

class FlashcardWidget extends StatelessWidget {
  final String word;
  final String definition;
  final CardState cardState;
  final VoidCallback onFlip;

  const FlashcardWidget({
    super.key,
    required this.word,
    required this.definition,
    required this.cardState,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardState == CardState.front ? onFlip : null,
      child: TweenAnimationBuilder(
        tween: Tween<double>(
          begin: 0,
          end: cardState == CardState.front ? 0 : 1,
        ),
        duration: const Duration(milliseconds: 300),
        builder: (context, double value, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(value * 3.14),
            alignment: Alignment.center,
            child: value < 0.5
                ? _buildFrontCard(context)
                : Transform(
                    transform: Matrix4.identity()..rotateX(3.14),
                    alignment: Alignment.center,
                    child: _buildBackCard(context),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (cardState == CardState.front)
              ElevatedButton.icon(
                onPressed: onFlip,
                icon: const Icon(Icons.flip),
                label: const Text('Virar Card'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Definição',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              definition,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
