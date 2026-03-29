import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class MeDashboardScreen extends ConsumerWidget {
  const MeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(meStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('${user?.role == UserRole.programManager ? "Program" : "M&E"} Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(meStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCards(stats),
              const SizedBox(height: 24),
              const Text('Impact & Quality Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildImpactCards(stats),
              const SizedBox(height: 24),
              const Text('Graduation Funnel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFunnelChart(stats),
              const SizedBox(height: 24),
              _buildActionHub(context),
              const SizedBox(height: 24),
              const Text('Regional Data Quality leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildRegionalQuality(),
              const SizedBox(height: 24),
              const Text('QC Verification Health', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildQcPieChart(stats),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCards(MeStatsEntity stats) {
    return Row(
      children: [
        _StatCard(
            label: 'Total Active',
            value: stats.totalActive.toString(),
            color: Colors.blue,
            icon: Icons.business),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Graduated',
            value: stats.totalGraduated.toString(),
            color: Colors.green,
            icon: Icons.school),
      ],
    );
  }

  Widget _buildImpactCards(MeStatsEntity stats) {
    return Row(
      children: [
        _StatCard(
            label: 'Avg Revenue Growth',
            value: '+42%',
            color: Colors.orange,
            icon: Icons.trending_up),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Jobs Created',
            value: '145',
            color: Colors.purple,
            icon: Icons.group_add),
      ],
    );
  }

  Widget _buildActionHub(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF311B92).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF311B92).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Management Tools', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF311B92))),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                label: 'Survey Hub',
                icon: Icons.assignment_outlined,
                onTap: () => context.push(AppRoutes.surveyHub),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                label: 'QC Queue',
                icon: Icons.verified_user_outlined,
                onTap: () => context.push(AppRoutes.qcDashboard),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelChart(MeStatsEntity stats) {
    final funnel = stats.graduationFunnel;
    final maxVal = [
      funnel['baseline'] ?? 1,
      funnel['training'] ?? 0,
      funnel['coaching'] ?? 0,
      funnel['midline'] ?? 0,
      funnel['graduated'] ?? 0
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal > 0 ? maxVal * 1.2 : 100,
          barGroups: [
            _makeGroupData(0, (funnel['baseline'] ?? 0).toDouble()),
            _makeGroupData(1, (funnel['training'] ?? 0).toDouble()),
            _makeGroupData(2, (funnel['coaching'] ?? 0).toDouble()),
            _makeGroupData(3, (funnel['midline'] ?? 0).toDouble()),
            _makeGroupData(4, (funnel['graduated'] ?? 0).toDouble()),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Base', 'Train', 'Coach', 'Mid', 'Grad'];
                  if (value.toInt() >= titles.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(titles[value.toInt()],
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF3D5AFE),
          width: 20,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildQcPieChart(MeStatsEntity stats) {
    final passed = stats.qcStats['passed'] ?? 0;
    final failed = stats.qcStats['failed'] ?? 0;
    final total = stats.qcStats['totalReview'] ?? (passed + failed);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                      color: Colors.green,
                      value: passed.toDouble(),
                      title: total > 0 ? '${(passed / total * 100).toInt()}%' : '0%',
                      radius: 25,
                      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(
                      color: Colors.red,
                      value: failed.toDouble(),
                      title: total > 0 ? '${(failed / total * 100).toInt()}%' : '0%',
                      radius: 25,
                      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(color: Colors.green, label: 'Audit Passed ($passed)'),
                const SizedBox(height: 8),
                _LegendItem(color: Colors.red, label: 'Audit Failed ($failed)'),
                const SizedBox(height: 12),
                Text('Total Audited: $total', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRegionalQuality() {
    final regions = [
      {'name': 'Addis Ababa', 'score': 98.5, 'color': Colors.green},
      {'name': 'Amhara', 'score': 94.2, 'color': Colors.green[400]},
      {'name': 'Oromia', 'score': 88.7, 'color': Colors.orange},
      {'name': 'Tigray', 'score': 82.1, 'color': Colors.red[300]},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: regions.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${r['score']}% Quality', style: TextStyle(color: r['color'] as Color, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (r['score'] as double) / 100,
                  backgroundColor: Colors.grey[100],
                  color: r['color'] as Color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF311B92).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF311B92), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF311B92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

