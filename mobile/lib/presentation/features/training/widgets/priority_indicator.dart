import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriorityIndicator extends StatelessWidget {
  final double priority;
  final int repetitions;
  final DateTime? nextReview;

  const PriorityIndicator({
    super.key,
    required this.priority,
    required this.repetitions,
    this.nextReview,
  });

  Color _getPriorityColor() {
    if (priority >= 0.7) return Colors.red;
    if (priority >= 0.4) return Colors.orange;
    return Colors.green;
  }

  String _getPriorityText() {
    if (priority >= 0.7) return 'Alta Prioridade';
    if (priority >= 0.4) return 'Média Prioridade';
    return 'Baixa Prioridade';
  }

  String _getNextReviewText() {
    if (nextReview == null) return 'Próxima revisão não definida';
    
    final now = DateTime.now();
    final difference = nextReview!.difference(now);
    
    if (difference.isNegative) {
      final days = difference.abs().inDays;
      return 'Atrasado há ${days} ${days == 1 ? 'dia' : 'dias'}';
    } else {
      return 'Próxima revisão: ${DateFormat('dd/MM/yyyy').format(nextReview!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.priority_high,
                color: _getPriorityColor(),
              ),
              const SizedBox(width: 8),
              Text(
                _getPriorityText(),
                style: TextStyle(
                  color: _getPriorityColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revisões: $repetitions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _getNextReviewText(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: priority,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getPriorityColor()),
            ),
          ),
        ],
      ),
    );
  }
}
