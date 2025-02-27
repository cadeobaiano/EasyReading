import 'package:flutter/material.dart';
import '../models/word_stats.dart';
import 'package:timeago/timeago.dart' as timeago;

class WordCardWidget extends StatelessWidget {
  final WordStats stats;
  final VoidCallback onTap;

  const WordCardWidget({
    Key? key,
    required this.stats,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.word,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          stats.translation,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildAccuracyBadge(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deck: ${stats.deckName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Revisões: ${stats.totalReviews}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Última revisão: ${_formatLastReview()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  _buildNextReviewIndicator(context),
                ],
              ),
              if (stats.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: stats.tags.map((tag) => _buildTagChip(tag)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getAccuracyColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAccuracyColor(),
          width: 2,
        ),
      ),
      child: Text(
        '${stats.accuracy.toStringAsFixed(0)}%',
        style: TextStyle(
          color: _getAccuracyColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNextReviewIndicator(BuildContext context) {
    final isOverdue = stats.nextReviewDue.isBefore(DateTime.now());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.warning : Icons.schedule,
          size: 16,
          color: isOverdue ? Colors.orange : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isOverdue
              ? 'Revisão pendente'
              : 'Próxima: ${timeago.format(stats.nextReviewDue)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOverdue ? Colors.orange : Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatLastReview() {
    return timeago.format(stats.lastReview);
  }

  Color _getAccuracyColor() {
    if (stats.accuracy >= 80) return Colors.green;
    if (stats.accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
