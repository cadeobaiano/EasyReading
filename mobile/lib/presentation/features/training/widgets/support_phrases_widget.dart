import 'package:flutter/material.dart';

class SupportPhrasesWidget extends StatelessWidget {
  final List<String> phrases;

  const SupportPhrasesWidget({
    super.key,
    required this.phrases,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frases de Apoio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...phrases.map((phrase) => _PhraseCard(phrase: phrase)),
      ],
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final String phrase;

  const _PhraseCard({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                phrase,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
