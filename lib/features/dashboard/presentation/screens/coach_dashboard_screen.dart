import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../enterprise/presentation/providers/enterprise_provider.dart';
import '../widgets/stat_card.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/metric_swiper.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/performance_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/activity_feed_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_navigation_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/add_session_screen.dart';

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
                          icon: Icons.calendar_month_rounded,
                          value: stats.totalSessions.toString(),
                          label: 'Today\'s Sessions',
                          subtitle: 'Scheduled sessions',
                          trend: '0',
                          trendUp: true,
                          gradient: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                          onTap: () => context.go('/sessions'),
                        ),
                        MetricSwiperItem(
                          icon: Icons.task_alt_rounded,
                          value: stats.pendingTasks.toString(),
                          label: 'Pending Tasks',
                          subtitle: 'Requires action',
                          trend: '0',
                          trendUp: false,
                          gradient: const [Color(0xFFFF6F00), Color(0xFFFFB300)],
                          onTap: () {},
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
                                  title: 'Add Session',
                                  icon: Icons.add_circle_outline_rounded,
                                  color: const Color(0xFF3D5AFE),
                                  onTap: () => context.push('/sessions/new'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'New Task',
                                  icon: Icons.playlist_add_rounded,
                                  color: const Color(0xFF00B09B),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Section: Recent Activity ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ActivityFeedWidget(
                        activities: stats.recentActivity,
                        onActivityTap: (activity) {
                          // Handle activity tap
                        },
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
      backgroundColor: const Color(0xFF3D5AFE),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
        title: const Text(
          'Coach Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3D5AFE), Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {},
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
