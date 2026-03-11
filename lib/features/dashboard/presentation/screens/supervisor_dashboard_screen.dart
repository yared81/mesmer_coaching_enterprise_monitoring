// TODO: Supervisor dashboard — shown to supervisor role
// Key stats: coaches count, enterprises monitored, average assessment score
// Charts: session frequency, enterprise improvement trend

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/stat_card.dart';

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(supervisorStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Institution Oversight',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(supervisorStatsProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institutional Health',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      title: 'My Coaches',
                      value: stats.totalCoaches.toString(),
                      icon: Icons.badge_rounded,
                      color: Colors.indigo,
                    ),
                    StatCard(
                      title: 'My Enterprises',
                      value: stats.totalEnterprises.toString(),
                      icon: Icons.storefront_rounded,
                      color: Colors.amber[800]!,
                    ),
                    StatCard(
                      title: 'Avg Progress',
                      value: '${(stats.avgAssessmentScore * 100).toInt()}%',
                      icon: Icons.analytics_rounded,
                      color: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.description, color: Colors.white),
                  ),
                  title: const Text('Generate Institution Report'),
                  subtitle: const Text('Export all enterprise status'),
                  trailing: const Icon(Icons.chevron_right),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
