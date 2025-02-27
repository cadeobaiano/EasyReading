import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/word_portal_bloc.dart';
import '../widgets/word_card_widget.dart';
import '../models/word_stats.dart';
import 'package:fl_chart/fl_chart.dart';

class WordPortalPage extends StatelessWidget {
  const WordPortalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordPortalBloc(
        wordPortalService: context.read(),
      )..add(WordPortalLoaded()),
      child: const WordPortalView(),
    );
  }
}

class WordPortalView extends StatefulWidget {
  const WordPortalView({Key? key}) : super(key: key);

  @override
  State<WordPortalView> createState() => _WordPortalViewState();
}

class _WordPortalViewState extends State<WordPortalView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Ver Palavras'),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar palavras...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () => _showFilterDialog(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          context
                              .read<WordPortalBloc>()
                              .add(WordPortalSearched(value));
                        },
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Lista'),
                        Tab(text: 'Estatísticas'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWordList(),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildWordList() {
    return BlocBuilder<WordPortalBloc, WordPortalState>(
      builder: (context, state) {
        if (state is WordPortalLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WordPortalLoaded) {
          if (state.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma palavra encontrada',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8),
            itemCount: state.words.length,
            itemBuilder: (context, index) {
              return WordCardWidget(
                stats: state.words[index],
                onTap: () => _showWordDetails(context, state.words[index]),
              );
            },
          );
        }

        return const Center(child: Text('Erro ao carregar palavras'));
      },
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<WordPortalBloc, WordPortalState>(
      builder: (context, state) {
        if (state is! WordPortalLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distribuição de Acertos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: state.maxWordsInCategory.toDouble(),
                    barGroups: state.accuracyDistribution.entries.map((entry) {
                      return BarChartGroupData(
                        x: int.parse(entry.key.split('-')[0]),
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: _getBarColor(int.parse(entry.key.split('-')[0])),
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}%');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildStatCard(
                'Total de Palavras',
                state.words.length.toString(),
                Icons.library_books,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Média de Acertos',
                '${state.averageAccuracy.toStringAsFixed(1)}%',
                Icons.grade,
                Colors.amber,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Palavras Dominadas',
                state.masteredWords.toString(),
                Icons.star,
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(int accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocBuilder<WordPortalBloc, WordPortalState>(
        builder: (context, state) {
          if (state is! WordPortalLoaded) {
            return const SizedBox.shrink();
          }

          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: Text(
                              'Filtros',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Taxa de Acerto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: RangeValues(
                              state.minAccuracyFilter ?? 0,
                              state.maxAccuracyFilter ?? 100,
                            ),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            labels: RangeLabels(
                              '${(state.minAccuracyFilter ?? 0).round()}%',
                              '${(state.maxAccuracyFilter ?? 100).round()}%',
                            ),
                            onChanged: (values) {
                              context.read<WordPortalBloc>().add(
                                    WordPortalFiltersChanged(
                                      minAccuracy: values.start,
                                      maxAccuracy: values.end,
                                    ),
                                  );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ordenar por',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildSortChip(
                                context,
                                'Alfabética',
                                'word',
                                state.sortBy,
                              ),
                              _buildSortChip(
                                context,
                                'Acertos',
                                'accuracy',
                                state.sortBy,
                              ),
                              _buildSortChip(
                                context,
                                'Última Revisão',
                                'lastReview',
                                state.sortBy,
                              ),
                              _buildSortChip(
                                context,
                                'Próxima Revisão',
                                'nextReview',
                                state.sortBy,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String label,
    String value,
    String? currentSort,
  ) {
    final isSelected = value == currentSort;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<WordPortalBloc>().add(WordPortalSortChanged(value));
        Navigator.pop(context);
      },
    );
  }

  void _showWordDetails(BuildContext context, WordStats stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    stats.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    stats.translation,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Deck', stats.deckName),
                _buildDetailRow(
                  'Taxa de Acerto',
                  '${stats.accuracy.toStringAsFixed(1)}%',
                ),
                _buildDetailRow('Total de Revisões', '${stats.totalReviews}'),
                _buildDetailRow(
                  'Última Revisão',
                  timeago.format(stats.lastReview),
                ),
                _buildDetailRow(
                  'Próxima Revisão',
                  timeago.format(stats.nextReviewDue),
                ),
                if (stats.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: stats.tags
                        .map((tag) => Chip(label: Text('#$tag')))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar revisão individual
                      Navigator.pop(context);
                    },
                    child: const Text('Revisar Agora'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
