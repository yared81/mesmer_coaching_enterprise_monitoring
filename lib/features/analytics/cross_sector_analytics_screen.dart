import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'analytics_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

class CrossSectorAnalyticsScreen extends ConsumerWidget {
  const CrossSectorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectorsAsync = ref.watch(sectorAnalyticsProvider);
    final regionsAsync = ref.watch(regionalAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-Sector Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sector Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSectorPieChart(sectorsAsync),
            const SizedBox(height: 40),
            const Text(
              'Performance by Sector (Avg IAP Progress)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSectorBarChart(sectorsAsync),
            const SizedBox(height: 40),
            const Text(
              'Regional Reach',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRegionalList(regionsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorPieChart(AsyncValue<List<SectorAnalytics>> sectorsAsync) {
    return sectorsAsync.when(
      data: (sectors) {
        if (sectors.isEmpty) return const Center(child: Text('No data available'));
        
        final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
        
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: PieChart(
            PieChartData(
              sections: sectors.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: s.count.toDouble(),
                  title: '${s.sector}\n${s.count}',
                  radius: 80,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildSectorBarChart(AsyncValue<List<SectorAnalytics>> sectorsAsync) {
    return sectorsAsync.when(
      data: (sectors) {
        if (sectors.isEmpty) return const SizedBox.shrink();
        
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barGroups: sectors.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.avgProgress.toDouble(),
                      color: AppColors.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final index = val.toInt();
                      if (index < 0 || index >= sectors.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(sectors[index].sector, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildRegionalList(AsyncValue<List<RegionalAnalytics>> regionsAsync) {
    return regionsAsync.when(
      data: (regions) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: regions.length,
          itemBuilder: (ctx, i) {
            final r = regions[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                ),
                title: Text(r.region, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Enterprises: ${r.enterpriseCount}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Avg Baseline', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(r.avgBaseline.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
