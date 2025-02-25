import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/deck.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final Function(bool) onToggleFeatured;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do Deck (se houver)
          if (deck.imageUrl != null)
            Image.network(
              deck.imageUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e Botão de Destaque
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        deck.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        deck.isFeatured ? Icons.star : Icons.star_border,
                        color: deck.isFeatured ? Colors.amber : null,
                      ),
                      onPressed: () => onToggleFeatured(!deck.isFeatured),
                      tooltip: deck.isFeatured
                          ? 'Remover dos destaques'
                          : 'Adicionar aos destaques',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Descrição
                Text(
                  deck.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Estatísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                      context,
                      Icons.style,
                      '${deck.cardCount} cartões',
                    ),
                    _buildStat(
                      context,
                      Icons.access_time,
                      _formatDate(deck.lastUpdated ?? deck.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
