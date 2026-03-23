import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/metric_swiper.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/widgets/program_funnel_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/widgets/regional_performance_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/activity_feed_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/sync_indicator.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';

class RegionalCoordinatorDashboardScreen extends ConsumerWidget {
  const RegionalCoordinatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(supervisorStatsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Regional Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (user?.institutionName != null)
              Text(
                user!.institutionName!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        actions: [
          SyncIndicator(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(supervisorStatsProvider.future),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user?.name ?? 'Coordinator'),
                const SizedBox(height: 24),
                
                // Metrics
                MetricSwiper(
                  items: [
                    MetricSwiperItem(
                      icon: Icons.business_rounded,
                      value: '${stats.totalEnterprises}',
                      label: 'Enterprises',
                      subtitle: 'Active Businesses',
                      trend: '+12%',
                      trendUp: true,
                      gradient: [const Color(0xFF3D5AFE), const Color(0xFF8C9EFF)],
                      onTap: () => context.go(AppRoutes.enterpriseList),
                    ),
                    MetricSwiperItem(
                      icon: Icons.person_rounded,
                      value: '${stats.totalCoaches}',
                      label: 'Coaches',
                      subtitle: 'Active in Region',
                      trend: '+2',
                      trendUp: true,
                      gradient: [const Color(0xFF00C853), const Color(0xFFB9F6CA)],
                      onTap: () => context.go(AppRoutes.coachList),
                    ),
                    MetricSwiperItem(
                      icon: Icons.assignment_turned_in_rounded,
                      value: '${stats.totalAssessments}',
                      label: 'Assessments',
                      subtitle: 'Forms Completed',
                      trend: '+24%',
                      trendUp: true,
                      gradient: [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Funnel (Region Scoped)
                const ProgramFunnelWidget(),
                
                const SizedBox(height: 32),
                
                // Coach Activity Feed
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                ActivityFeedWidget(
                  activities: stats.recentActivity,
                  onActivityTap: (activity) {},
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is what\'s happening in your region today.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
