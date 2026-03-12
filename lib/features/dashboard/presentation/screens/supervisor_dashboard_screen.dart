import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/performance_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/activity_feed_widget.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/app_search_bar.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_navigation_provider.dart';

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Mark all as read')),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.info_outline, color: Colors.white)),
              title: const Text('System Update'),
              subtitle: const Text('Service maintenance scheduled for tonight at 2 AM.'),
              trailing: const Text('2h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check_circle_outline, color: Colors.white)),
              title: const Text('New Enterprise Registered'),
              subtitle: const Text('Global Tech Solutions has joined the program.'),
              trailing: const Text('5h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(supervisorStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(supervisorStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                centerTitle: true,
                leadingWidth: 120, // Give enough space for institution name
                leading: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'MESMER HQ', // Extracted from context
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                title: const Text(
                  'Supervisor Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  const AppSearchBar(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => _showNotificationsSheet(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Program Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          StatCard(
                            title: 'Active Coaches',
                            value: stats.totalCoaches.toString(),
                            icon: Icons.people_alt_rounded,
                            color: Colors.indigo,
                            onTap: () => ref.read(dashboardIndexProvider.notifier).state = 1,
                          ),
                          StatCard(
                            title: 'Enterprises',
                            value: stats.totalEnterprises.toString(),
                            icon: Icons.storefront_rounded,
                            color: Colors.amber[800]!,
                            onTap: () => ref.read(dashboardIndexProvider.notifier).state = 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const ProgramPerformanceChart(),
                      const SizedBox(height: 32),
                      ActivityFeedWidget(
                        activities: stats.recentActivity,
                        onActivityTap: (activity) {
                          if (activity.type == 'enterprise') {
                            ref.read(dashboardIndexProvider.notifier).state = 2;
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
