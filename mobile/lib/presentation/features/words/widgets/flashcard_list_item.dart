import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/flashcard.dart';

class FlashcardListItem extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback? onTap;

  const FlashcardListItem({
    super.key,
    required this.flashcard,
    this.onTap,
  });

  Color _getDifficultyColor(BuildContext context) {
    if (flashcard.easeFactor >= 2.5) {
      return Colors.green;
    } else if (flashcard.easeFactor >= 1.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getFormattedDate() {
    if (flashcard.lastReviewDate == null) return 'Não revisado';
    return '${flashcard.lastReviewDate!.day}/${flashcard.lastReviewDate!.month}/${flashcard.lastReviewDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flashcard.word,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: _getDifficultyColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(flashcard.successRate * 100).toInt()}%',
                          style: TextStyle(
                            color: _getDifficultyColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Última revisão: ${_getFormattedDate()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Repetições: ${flashcard.repetitions}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
