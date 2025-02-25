import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/user_profile.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsSection extends StatelessWidget {
  final UserStatistics statistics;

  const StatisticsSection({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas de Aprendizado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Gráfico de Progresso
            SizedBox(
              height: 200,
              child: LineChart(
                _createChartData(context),
              ),
            ),
            const SizedBox(height: 24),

            // Estatísticas Detalhadas
            _buildDetailedStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return Column(
      children: [
        _buildStatRow(
          context,
          'Total de Sessões',
          statistics.totalSessions.toString(),
          Icons.timer,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Cartões Revisados',
          statistics.totalReviews.toString(),
          Icons.repeat,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Tempo Total de Estudo',
          _formatStudyTime(statistics.totalStudyTimeMinutes),
          Icons.access_time,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Média de Acertos',
          '${(statistics.averageAccuracy * 100).toInt()}%',
          Icons.analytics,
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatStudyTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours h ${remainingMinutes}min';
    }
    return '${remainingMinutes}min';
  }

  LineChartData _createChartData(BuildContext context) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value % 2 == 0) {
                return Text(
                  'Dia ${value.toInt() + 1}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: statistics.dailyProgress
              .asMap()
              .entries
              .map((entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value.cardsReviewed.toDouble(),
                  ))
              .toList(),
          isCurved: true,
          color: Theme.of(context).primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
        ),
      ],
      minY: 0,
    );
  }
}
