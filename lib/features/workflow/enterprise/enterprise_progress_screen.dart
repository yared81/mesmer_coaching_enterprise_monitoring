import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'enterprise_provider.dart';
import 'enterprise_dashboard_stats.dart';
import 'enterprise_entity.dart';

class EnterpriseProgressScreen extends ConsumerWidget {
  const EnterpriseProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(enterpriseDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) {
          // Pull baseline score from the enterprise entity if available
          final user = ref.read(authProvider).user;
          final enterpriseId = user?.enterpriseId ?? '';
          final enterpriseAsync = ref.watch(enterpriseDetailProvider(enterpriseId));
          final baselineScore = enterpriseAsync.maybeWhen(
            data: (e) => e.baselineScore ?? 0.0,
            orElse: () => 0.0,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildScoreOverview(stats, baselineScore),
              const SizedBox(height: 24),
              _buildRadarChart(stats),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(stats),
              const SizedBox(height: 24),
              _buildLatestRecommendation(stats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreOverview(EnterpriseDashboardStats stats, double baselineScore) {
    final currentScore = stats.radarScores.isEmpty
        ? 0.0
        : stats.radarScores.map((e) => e.value).reduce((a, b) => a + b) / stats.radarScores.length;
    final improvement = currentScore - baselineScore;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Business Health Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScorePill('Baseline', baselineScore, Colors.grey),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildScorePill('Current', currentScore, Colors.blue),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: improvement >= 0 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        improvement >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: improvement >= 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      Text(
                        '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: improvement >= 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text('Growth', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorePill(String label, double score, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(0),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRadarChart(EnterpriseDashboardStats stats) {
    if (stats.radarScores.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.radar, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No assessment data yet.\nComplete your first coaching session to see scores.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Skills Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.25),
                      borderColor: Colors.blue,
                      entryRadius: 4,
                      dataEntries: stats.radarScores.map((e) => RadarEntry(value: e.value)).toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  getTitle: (index, angle) => RadarChartTitle(text: stats.radarScores[index].name),
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  gridBorderData: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(EnterpriseDashboardStats stats) {
    if (stats.radarScores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...stats.radarScores.map((score) {
          final pct = (score.value / 100).clamp(0.0, 1.0);
          final color = pct >= 0.7 ? Colors.green : pct >= 0.4 ? Colors.orange : Colors.red;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(score.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('${score.value.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  color: color,
                  backgroundColor: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLatestRecommendation(EnterpriseDashboardStats stats) {
    if (stats.latestRecommendation.isEmpty || stats.latestRecommendation == 'No recommendations yet.') {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Coach's Recommendation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(stats.latestRecommendation, style: const TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }
}
