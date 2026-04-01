import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_provider.dart';
import 'stat_card.dart';

import 'package:mesmer_digital_coaching/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_digital_coaching/features/dashboard/metric_swiper.dart';
import 'package:mesmer_digital_coaching/features/dashboard/performance_chart.dart';
import 'package:mesmer_digital_coaching/core/sync/sync_service.dart';
import 'package:mesmer_digital_coaching/features/dashboard/activity_feed_widget.dart';
import 'package:mesmer_digital_coaching/features/dashboard/activity_provider.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_navigation_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/coaching/add_session_screen.dart';
import 'package:mesmer_digital_coaching/core/widgets/notification_bell.dart';

class _LiveActivityFeed extends ConsumerWidget {
  const _LiveActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityFeedProvider);

    return activityAsync.when(
      data: (items) => ActivityFeedWidget(
        activities: items,
        onActivityTap: (activity) {
          // Navigation logic based on type
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading feed: $err')),
    );
  }
}

class CoachDashboardScreen extends ConsumerWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final coachStatsAsync = ref.watch(coachStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: coachStatsAsync.when(
        data: (stats) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, ref, user?.name ?? 'Coach'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Metric Swiper ───────────────────────────────────────
                    MetricSwiper(
                      items: [
                        MetricSwiperItem(
                          icon: Icons.business_center_rounded,
                          value: stats.totalEnterprises.toString(),
                          label: 'My Enterprises',
                          subtitle: 'Assigned to you',
                          trend: '+${stats.totalEnterprises}',
                          trendUp: true,
                          gradient: const [Color(0xFF3D5AFE), Color(0xFF8C9EFF)],
                          onTap: () => context.go(AppRoutes.enterpriseList),
                        ),
                        MetricSwiperItem(
                          icon: Icons.person_pin_rounded,
                          value: 'Portfolio',
                          label: 'My Portfolio',
                          subtitle: 'Coach CRM View',
                          trend: 'LIVE',
                          trendUp: true,
                          gradient: const [Color(0xFF8E24AA), Color(0xFFBA68C8)],
                          onTap: () => context.push(AppRoutes.coachCrm),
                        ),
                        MetricSwiperItem(
                          icon: Icons.calendar_month_rounded,
                          value: stats.totalSessions.toString(),
                          label: 'Sessions',
                          subtitle: 'History & Logs',
                          trend: 'View All',
                          trendUp: true,
                          gradient: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                          onTap: () => context.go('/sessions'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Section: Performance ────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ProgramPerformanceChart(),
                    ),

                    const SizedBox(height: 32),

                    // ── Section: Quick Actions ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'Record Session',
                                  icon: Icons.add_circle_outline_rounded,
                                  color: const Color(0xFF3D5AFE),
                                  onTap: () => context.push('/sessions/new'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'Schedule Future',
                                  icon: Icons.calendar_today_rounded,
                                  color: Colors.deepPurple,
                                  onTap: () => context.push('/calendar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Section: Live Interaction Feed ──────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Interaction Feed',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextButton(
                                onPressed: () => ref.invalidate(activityFeedProvider),
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _LiveActivityFeed(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, String name) {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
        title: const Text(
          'Coach Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_sync_rounded),
          tooltip: 'Sync Offline Data',
          onPressed: () async {
            try {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing offline data...')));
              await ref.read(syncServiceProvider).syncQueue();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed successfully.')));
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
            }
          },
        ),
        const NotificationBell(),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          onPressed: () => context.go(AppRoutes.chat),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
