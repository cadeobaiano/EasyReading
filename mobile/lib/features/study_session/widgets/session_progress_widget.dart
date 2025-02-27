import 'package:flutter/material.dart';

class SessionProgressWidget extends StatelessWidget {
  final int currentCard;
  final int totalCards;
  final int correctAnswers;

  const SessionProgressWidget({
    Key? key,
    required this.currentCard,
    required this.totalCards,
    required this.correctAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card $currentCard de $totalCards',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '$correctAnswers',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentCard / totalCards,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
