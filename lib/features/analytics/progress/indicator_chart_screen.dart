import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'progress_provider.dart';

class IndicatorChartScreen extends ConsumerWidget {
  final String enterpriseId;
  const IndicatorChartScreen({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(enterpriseProgressProvider(enterpriseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Breakdown'),
        elevation: 0,
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('No data available',
              style: TextStyle(color: Theme.of(context).hintColor)),
        ),
        data: (progress) {
          if (progress.indicators.isEmpty) {
            return const Center(
              child: Text('No category data yet.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          final categories = progress.indicators.keys.toList();
          final scores = progress.indicators.values.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bar Chart ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score per Category (Max 5.0)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Based on latest completed assessment',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 5,
                          minY: 0,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                                  BarTooltipItem(
                                '${categories[groupIndex]}\n${rod.toY.toStringAsFixed(1)} / 5.0',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              ),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48,
                                getTitlesWidget: (v, m) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= categories.length)
                                    return const SizedBox.shrink();
                                  final words = categories[i].split(' ');
                                  final abbr = words.length >= 2
                                      ? words
                                          .take(2)
                                          .map((w) => w[0].toUpperCase())
                                          .join()
                                      : categories[i]
                                          .substring(0, categories[i].length.clamp(0, 4))
                                          .toUpperCase();
                                  return SideTitleWidget(
                                    meta: m,
                                    space: 8,
                                    child: Text(abbr,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 24,
                                getTitlesWidget: (v, m) => SideTitleWidget(
                                  meta: m,
                                  child: Text(v.toInt().toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.15),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(categories.length, (i) {
                            final score = scores[i].clamp(0.0, 5.0);
                            final color = score >= 4
                                ? Colors.green
                                : score >= 2.5
                                    ? AppColors.primary
                                    : Colors.red;
                            return BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: score,
                                color: color,
                                width: 22,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ]);
                          }),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Detail Table ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Breakdown',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 16),
                      ...List.generate(categories.length, (i) {
                        final score = scores[i];
                        final pct = (score / 5.0).clamp(0.0, 1.0);
                        final color = score >= 4
                            ? Colors.green
                            : score >= 2.5
                                ? AppColors.primary
                                : Colors.red;
                        final status = score >= 4
                            ? 'Strong'
                            : score >= 2.5
                                ? 'Moderate'
                                : 'Needs Work';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(categories[i],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          '${score.toStringAsFixed(1)} / 5.0',
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(status,
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
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
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
