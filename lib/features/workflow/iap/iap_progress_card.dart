import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'iap_provider.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';

/// Displays a progress ring and key stats for an IAP.
/// Pass the [iapId] and it fetches live stats from the backend.
class IapProgressCard extends ConsumerWidget {
  final String iapId;
  const IapProgressCard({super.key, required this.iapId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(iapProgressProvider(iapId));

    return statsAsync.when(
      data: (stats) => _buildCard(context, stats),
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, IapProgressStats stats) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Donut ring ───────────────────────────────────────────────────
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: stats.total == 0
                          ? [
                              PieChartSectionData(
                                value: 1,
                                color: Colors.grey.shade200,
                                radius: 14,
                                showTitle: false,
                              )
                            ]
                          : [
                              PieChartSectionData(
                                value: stats.completed.toDouble(),
                                color: Colors.green,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: stats.overdue.toDouble(),
                                color: Colors.red,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: (stats.pending - stats.overdue)
                                    .clamp(0, stats.total)
                                    .toDouble(),
                                color: Colors.orange.shade200,
                                radius: 14,
                                showTitle: false,
                              ),
                            ],
                    ),
                  ),
                  Text(
                    '${stats.percentage}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // ── Stats ────────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Action Plan Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip('${stats.completed} Done', Colors.green),
                      _chip('${stats.pending} Pending', Colors.orange),
                      if (stats.overdue > 0)
                        _chip('${stats.overdue} Overdue', Colors.red),
                      _chip('${stats.total} Total', AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
