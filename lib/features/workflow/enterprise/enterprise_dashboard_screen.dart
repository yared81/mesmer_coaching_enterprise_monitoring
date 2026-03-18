import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'enterprise_provider.dart';
import 'enterprise_dashboard_stats.dart';

class EnterpriseDashboardScreen extends ConsumerWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(enterpriseDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              // Notifications logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              context.go(AppRoutes.chat);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, stats),
              const SizedBox(height: 24),
              _buildRadarChart(stats),
              const SizedBox(height: 24),
              _buildActionPlan(stats),
              const SizedBox(height: 24),
              _buildQuickStats(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EnterpriseDashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Welcome, ${stats.businessName}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                context.go(AppRoutes.enterpriseProfile);
              },
              icon: const Icon(Icons.account_circle_outlined, size: 18),
              label: const Text('Profile'),
            ),
          ],
        ),
        Text(
          '${stats.sector} Sector • Growth Journey',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRadarChart(EnterpriseDashboardStats stats) {
    if (stats.radarScores.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.assessment_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Waiting for your first assessment results...', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Business Health Index', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Expanded(
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        fillColor: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        entryRadius: 3,
                        dataEntries: stats.radarScores
                            .map((e) => RadarEntry(value: e.value))
                            .toList(),
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    getTitle: (index, angle) {
                      return RadarChartTitle(text: stats.radarScores[index].name);
                    },
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPlan(EnterpriseDashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                "Coach's Priority",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stats.latestRecommendation,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {}, // Link to tasks later
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Full Action Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(EnterpriseDashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Sessions',
            stats.totalSessions.toString(),
            Icons.history,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Last Visit',
            stats.lastSessionDate != null 
                ? stats.lastSessionDate!.substring(0, 10) 
                : 'Never',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
