import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/animated_progress_ring.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Olá, Eduardo!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
            centerTitle: false,
            titlePadding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing['md']!,
              vertical: AppTheme.spacing['sm']!,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.background,
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(AppTheme.spacing['md']!),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Progresso
                Semantics(
                  label: 'Seu progresso diário',
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing['md']!),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seu Progresso',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Continue praticando para manter seu ritmo!',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: AnimatedProgressRing(
                                  progress: 0.75,
                                  duration: AppTheme.longAnimation,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implementar ação de praticar
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Praticar Agora'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Estatísticas
                Text(
                  'Estatísticas',
                  style: theme.textTheme.titleLarge,
                  semanticsLabel: 'Seção de estatísticas',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.timer,
                        value: '15',
                        label: 'Dias Seguidos',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.auto_awesome,
                        value: '85%',
                        label: 'Precisão',
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ações Rápidas
                Text(
                  'Ações Rápidas',
                  style: theme.textTheme.titleLarge,
                  semanticsLabel: 'Seção de ações rápidas',
                ),
                const SizedBox(height: 16),
                ActionCard(
                  title: 'Revisar Erros',
                  subtitle: 'Pratique palavras que você errou recentemente',
                  icon: Icons.refresh,
                  onTap: () {
                    // TODO: Implementar revisão de erros
                  },
                ),
                const SizedBox(height: 12),
                ActionCard(
                  title: 'Ver Todas as Palavras',
                  subtitle: 'Explore todas as palavras em seus decks',
                  icon: Icons.list_alt,
                  onTap: () {
                    // TODO: Implementar visualização de palavras
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
