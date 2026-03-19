import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/iap/iap_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/iap/iap_entity.dart';
import 'package:intl/intl.dart';
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
              _buildActionPlan(context, ref),
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

  Widget _buildActionPlan(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final enterpriseId = user?.enterpriseId;

    if (enterpriseId == null) {
      return const SizedBox.shrink();
    }

    final iapsAsync = ref.watch(enterpriseIapsProvider(enterpriseId));

    return iapsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading plan: $err')),
      data: (iaps) {
        if (iaps.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text("Coach's Priority", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12),
                Text('Waiting for coach to assign first Action Plan.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }

        final iap = iaps.first; // active IAP
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Specific Action Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...iap.tasks.map((task) => _buildTaskCard(task)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(IapTaskEntity task) {
    final isDone = task.status == IapTaskStatus.completed;
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !isDone;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? Colors.green : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: isOverdue ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                      style: TextStyle(color: isOverdue ? Colors.red : Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                if (!isDone && task.evidenceUrl == null)
                  ElevatedButton.icon(
                    onPressed: () { 
                      // Trigger file upload picker placeholder
                    },
                    icon: const Icon(Icons.cloud_upload, size: 14),
                    label: const Text('Upload Evidence'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                else if (task.evidenceUrl != null)
                   const Text('Evidence Uploaded', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
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
