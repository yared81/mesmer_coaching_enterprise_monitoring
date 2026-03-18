import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/stat_card.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/activity_feed_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/app_search_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

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
                  'System Alerts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Clear All')),
              ],
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.warning_amber_rounded, color: Colors.white)),
              title: Text('Low Performance Alert'),
              subtitle: Text('Institution "FastTrack" showing 15% drop in activity.'),
              trailing: Text('1h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person_add_outlined, color: Colors.white)),
              title: Text('New Admin Multi-factor request'),
              subtitle: Text('Supervisor "John Doe" requested 2FA reset.'),
              trailing: Text('3h ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(adminStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                centerTitle: true,
                title: const Text(
                  'Admin Dashboard',
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
                        'System Statistics',
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
                            title: 'Programs',
                            value: stats.activePrograms.toString(),
                            icon: Icons.assignment_rounded,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'Institutions',
                            value: stats.totalInstitutions.toString(),
                            icon: Icons.business_rounded,
                            color: Colors.blue,
                          ),
                          StatCard(
                            title: 'Coaches',
                            value: stats.totalCoaches.toString(),
                            icon: Icons.people_rounded,
                            color: Colors.purple,
                          ),
                          StatCard(
                            title: 'Enterprises',
                            value: stats.totalEnterprises.toString(),
                            icon: Icons.store_rounded,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ActivityFeedWidget(activities: stats.recentEnterprises),
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

