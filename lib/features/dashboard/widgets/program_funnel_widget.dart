import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_entity.dart';

class ProgramFunnelWidget extends ConsumerWidget {
  const ProgramFunnelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(meStatsProvider);

    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Funnel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildFunnelChart(context, stats),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(), // Silently fail for other roles if they don't have access
    );
  }

  Widget _buildFunnelChart(BuildContext context, MeStatsEntity stats) {
    final funnel = stats.graduationFunnel;
    final stages = [
      {'key': 'outreach', 'label': 'Outreach', 'color': const Color(0xFF6366F1)},
      {'key': 'baseline', 'label': 'Baseline', 'color': const Color(0xFF4F46E5)},
      {'key': 'training', 'label': 'Training', 'color': const Color(0xFF4338CA)},
      {'key': 'coaching', 'label': 'Coaching', 'color': const Color(0xFF3730A3)},
      {'key': 'midline', 'label': 'Midline', 'color': const Color(0xFF312E81)},
      {'key': 'graduated', 'label': 'Graduated', 'color': const Color(0xFF10B981)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final stage = stages[index];
          final count = funnel[stage['key']] ?? 0;
          final prevCount = index > 0 ? (funnel[stages[index - 1]['key']] ?? 0) : count;
          final conversion = prevCount > 0 ? (count / prevCount * 100).round() : 0;
          final isFirst = index == 0;

          // Width calculation: relative to first stage
          final firstCount = funnel['outreach'] ?? 1;
          final widthFactor = firstCount > 0 ? (count / firstCount).clamp(0.4, 1.0) : 1.0;

          return Column(
            children: [
              if (!isFirst)
                _buildConversionArrow(context, conversion),
              _buildFunnelStep(
                label: stage['label'] as String,
                count: count,
                color: stage['color'] as Color,
                widthFactor: widthFactor,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFunnelStep({
    required String label,
    required int count,
    required Color color,
    required double widthFactor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversionArrow(BuildContext context, int percentage) {
    return Container(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            color: Colors.grey.withOpacity(0.2),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: percentage > 80 ? Colors.green : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    // Keep for potential legacy use or remove if sure
    return BarChartGroupData(x: x);
  }
}
