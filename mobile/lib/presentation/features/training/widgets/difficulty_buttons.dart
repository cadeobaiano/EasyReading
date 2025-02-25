import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/training_session_state.dart';

class DifficultyButtons extends StatelessWidget {
  final Function(DifficultyLevel) onDifficultySelected;

  const DifficultyButtons({
    super.key,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DifficultyButton(
            difficulty: DifficultyLevel.hard,
            color: Colors.red[400]!,
            onTap: () => onDifficultySelected(DifficultyLevel.hard),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DifficultyButton(
            difficulty: DifficultyLevel.medium,
            color: Colors.orange[400]!,
            onTap: () => onDifficultySelected(DifficultyLevel.medium),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DifficultyButton(
            difficulty: DifficultyLevel.easy,
            color: Colors.green[400]!,
            onTap: () => onDifficultySelected(DifficultyLevel.easy),
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final DifficultyLevel difficulty;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.color,
    required this.onTap,
  });

  String get _label {
    switch (difficulty) {
      case DifficultyLevel.hard:
        return 'Difícil';
      case DifficultyLevel.medium:
        return 'Médio';
      case DifficultyLevel.easy:
        return 'Fácil';
    }
  }

  IconData get _icon {
    switch (difficulty) {
      case DifficultyLevel.hard:
        return Icons.sentiment_very_dissatisfied;
      case DifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case DifficultyLevel.easy:
        return Icons.sentiment_very_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon),
          const SizedBox(height: 4),
          Text(_label),
        ],
      ),
    );
  }
}
