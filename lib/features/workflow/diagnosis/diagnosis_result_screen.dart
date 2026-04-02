import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'diagnosis_provider.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  final String assessmentId;
  const DiagnosisResultScreen({super.key, required this.assessmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(existingDiagnosisReportProvider(assessmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
        elevation: 0,
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Could not load result: $e',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        data: (report) {
          if (report == null) {
            return const Center(
              child: Text('No assessment result found.',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return _buildResult(context, report);
        },
      ),
    );
  }

  Widget _buildResult(BuildContext context, Map<String, dynamic> report) {
    final healthPct =
        NumUtils.toDouble(report['health_percentage'] ?? report['healthPercentage']);
    final categoryScores = (report['category_scores'] ??
        report['categoryScores']) as Map<String, dynamic>?;
    final recommendation =
        report['recommendation']?.toString() ?? '';

    final color = healthPct >= 80
        ? Colors.green
        : healthPct >= 50
            ? Colors.orange
            : Colors.red;
    final label = healthPct >= 80
        ? 'Healthy'
        : healthPct >= 50
            ? 'Moderate'
            : 'Needs Support';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Overall Score ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '${healthPct.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: color),
                ),
                Text(label,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 8),
                Text('Overall Business Health Score',
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Category Breakdown ─────────────────────────────────────────
          if (categoryScores != null && categoryScores.isNotEmpty) ...[
            const Text('Category Breakdown',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) {
                          final keys = categoryScores.keys.toList();
                          final i = v.toInt();
                          if (i < 0 || i >= keys.length)
                            return const SizedBox.shrink();
                          final name = keys[i]
                              .replaceFirst(RegExp(r'^\d+\.\s*'), '');
                          final abbr = name.length > 4
                              ? name.substring(0, 4).toUpperCase()
                              : name.toUpperCase();
                          return SideTitleWidget(
                              meta: m,
                              child: Text(abbr,
                                  style: const TextStyle(fontSize: 9)));
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
                              style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: categoryScores.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
                    final score = NumUtils.toDouble(
                        e.value.value['score'] ??
                            e.value.value['average_score']);
                    final barColor = score >= 4
                        ? Colors.green
                        : score >= 2.5
                            ? AppColors.primary
                            : Colors.red;
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(
                          toY: score.clamp(0, 5),
                          color: barColor,
                          width: 18,
                          borderRadius: BorderRadius.circular(4))
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...categoryScores.entries.map((e) {
              final name =
                  e.key.replaceFirst(RegExp(r'^\d+\.\s*'), '');
              final score = NumUtils.toDouble(
                  e.value['score'] ?? e.value['average_score']);
              final pct = score / 5.0;
              final barColor = score >= 4
                  ? Colors.green
                  : score >= 2.5
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
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('${score.toStringAsFixed(1)} / 5.0',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: barColor,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        color: barColor,
                        backgroundColor:
                            Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Recommendation ─────────────────────────────────────────────
          if (recommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recommendation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(recommendation,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
