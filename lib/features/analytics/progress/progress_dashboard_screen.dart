import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'progress_provider.dart';
import 'progress_entity.dart';
import 'indicator_chart_screen.dart';

class ProgressDashboardScreen extends ConsumerWidget {
  final String enterpriseId;
  const ProgressDashboardScreen({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(enterpriseProgressProvider(enterpriseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        elevation: 0,
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text('No progress data yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).hintColor)),
              const SizedBox(height: 8),
              Text('Complete coaching sessions to track improvement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        data: (progress) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(enterpriseProgressProvider(enterpriseId).future),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ScoreComparisonCard(progress: progress),
              const SizedBox(height: 20),
              if (progress.trends.length >= 2)
                _TrendLineCard(progress: progress),
              if (progress.trends.length >= 2) const SizedBox(height: 20),
              _CategoryBreakdownCard(
                  progress: progress, enterpriseId: enterpriseId),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Comparison Card ─────────────────────────────────────────────────────
class _ScoreComparisonCard extends StatelessWidget {
  final ProgressEntity progress;
  const _ScoreComparisonCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final improved = progress.improvementPercentage >= 0;
    final color = improved ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.9), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Business Health Score',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScorePill(
                  label: 'Baseline',
                  score: progress.baselineScore,
                  color: Colors.white54),
              Column(
                children: [
                  Icon(
                      improved
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: improved ? Colors.greenAccent : Colors.redAccent,
                      size: 28),
                  const SizedBox(height: 4),
                  Text(
                    '${improved ? '+' : ''}${progress.improvementPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: improved ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
              _ScorePill(
                  label: 'Current',
                  score: progress.latestScore,
                  color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: ${DateFormat('MMM dd, yyyy').format(progress.lastUpdated)}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  const _ScorePill(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(score.toStringAsFixed(0),
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900, color: color)),
        Text(label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}

// ── Trend Line Card ───────────────────────────────────────────────────────────
class _TrendLineCard extends StatelessWidget {
  final ProgressEntity progress;
  const _TrendLineCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final trends = progress.trends;
    final parsedDates =
        trends.map((t) => DateTime.tryParse(t['date'] ?? '') ?? DateTime.now()).toList();
    final first = parsedDates.reduce((a, b) => a.isBefore(b) ? a : b);

    final spots = List.generate(trends.length, (i) {
      final hours = parsedDates[i].difference(first).inHours.toDouble();
      final score = (trends[i]['score'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(hours, score);
    });

    final maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Trend',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface)),
          Text('${trends.length} sessions recorded',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              maxY: 5,
              minY: 0,
              minX: 0,
              maxX: maxX > 0 ? maxX : 24,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, m) {
                      final idx = spots.indexWhere((s) => (s.x - v).abs() < 1);
                      if (idx < 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: m,
                        child: Text(
                          DateFormat('MMM dd').format(parsedDates[idx]),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 20,
                    getTitlesWidget: (v, m) => SideTitleWidget(
                      meta: m,
                      child: Text(v.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

// ── Category Breakdown Card ───────────────────────────────────────────────────
class _CategoryBreakdownCard extends StatelessWidget {
  final ProgressEntity progress;
  final String enterpriseId;
  const _CategoryBreakdownCard(
      {required this.progress, required this.enterpriseId});

  @override
  Widget build(BuildContext context) {
    if (progress.indicators.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category Scores',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface)),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        IndicatorChartScreen(enterpriseId: enterpriseId),
                  ),
                ),
                child: const Text('Full Chart →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...progress.indicators.entries.map((e) {
            final pct = (e.value / 5.0).clamp(0.0, 1.0);
            final color = e.value >= 4
                ? Colors.green
                : e.value >= 2.5
                    ? AppColors.primary
                    : Colors.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      Text('${e.value.toStringAsFixed(1)} / 5.0',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      color: color,
                      backgroundColor: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
