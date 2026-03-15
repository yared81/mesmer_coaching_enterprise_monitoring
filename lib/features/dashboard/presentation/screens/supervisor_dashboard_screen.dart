import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_navigation_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/metric_swiper.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/performance_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/coach_activity_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/activity_feed_widget.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/widgets/app_search_bar.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

  // ── Profile Quick-Menu ─────────────────────────────────────────────────────
  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Avatar + Name
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF3D5AFE),
                child: Text(
                  'SV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Supervisor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const Text(
                'supervisor@mesmer.com',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              const Divider(),
              _ProfileMenuTile(
                icon: Icons.person_outline_rounded,
                label: 'View Profile',
                onTap: () => Navigator.pop(ctx),
              ),
              _ProfileMenuTile(
                icon: Icons.swap_horiz_rounded,
                label: 'Switch Institution',
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
              _ProfileMenuTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(ctx);
                  final double check = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out of your account?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 0.0),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 1.0),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ) ?? 0.0;
                  
                  if (check == 1.0) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Notifications Sheet ────────────────────────────────────────────────────
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Mark all read')),
              ],
            ),
            const SizedBox(height: 8),
            _NotificationTile(
              icon: Icons.check_circle_rounded,
              iconColor: Colors.green,
              title: 'New Enterprise Registered',
              subtitle: 'Global Tech Solutions has joined.',
              time: '2h ago',
            ),
            _NotificationTile(
              icon: Icons.warning_rounded,
              iconColor: Colors.orange,
              title: 'Score Alert',
              subtitle: 'Sunrise Bakery has dropped below 40%.',
              time: '5h ago',
            ),
            _NotificationTile(
              icon: Icons.info_rounded,
              iconColor: Colors.blue,
              title: 'System Maintenance',
              subtitle: 'Scheduled tonight at 2:00 AM.',
              time: '1d ago',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(supervisorStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(supervisorStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── App Bar ────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 80.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF3D5AFE),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
                  title: const Text(
                    'Supervisor Dashboard',
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
                    onPressed: () => _showNotificationsSheet(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── Body Content ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Section: Metric Swiper ──────────────────────────────
                    MetricSwiper(
                      items: [
                        MetricSwiperItem(
                          icon: Icons.storefront_rounded,
                          value: stats.totalEnterprises.toString(),
                          label: 'Enterprises',
                          subtitle: 'Under this program',
                          trend: '+12%',
                          trendUp: true,
                          gradient: const [Color(0xFF3D5AFE), Color(0xFF6979F8)],
                          onTap: () => context.go(AppRoutes.enterpriseList),
                        ),
                        MetricSwiperItem(
                          icon: Icons.people_alt_rounded,
                          value: stats.totalCoaches.toString(),
                          label: 'Active Coaches',
                          subtitle: 'Currently coaching',
                          trend: '+2',
                          trendUp: true,
                          gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                          onTap: () => context.go('/coaches'),
                        ),
                        MetricSwiperItem(
                          icon: Icons.handshake_rounded,
                          value: '0',
                          label: 'Sessions',
                          subtitle: 'Conducted this month',
                          trend: '0',
                          trendUp: true,
                          gradient: const [Color(0xFFFF6F00), Color(0xFFFFB300)],
                        ),
                        MetricSwiperItem(
                          icon: Icons.warning_amber_rounded,
                          value: '0',
                          label: 'Needs Attention',
                          subtitle: 'Low performance score',
                          trend: '0',
                          trendUp: false,
                          gradient: const [Color(0xFFE53935), Color(0xFFEF9A9A)],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Section: Performance Charts ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionHeader(
                        title: 'Program Performance',
                        subtitle: 'Growth & activity overview',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ProgramPerformanceChart(),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: CoachActivityChart(),
                    ),

                    const SizedBox(height: 28),

                    const SizedBox(height: 28),

                    // ── Section: Recent Activity ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionHeader(
                        title: 'Recent Activity',
                        subtitle: 'Latest system events',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ActivityFeedWidget(
                        activities: stats.recentActivity,
                        onActivityTap: (activity) {
                          if (activity.type == 'enterprise') {
                            context.go(AppRoutes.enterpriseList);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Section: Quick Actions ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionHeader(title: 'Quick Actions'),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.bar_chart_rounded,
                              label: 'Reports',
                              color: const Color(0xFF3D5AFE),
                              onTap: () => context.go(AppRoutes.supervisorReports),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.people_outline_rounded,
                              label: 'All Coaches',
                              color: const Color(0xFF00B09B),
                              onTap: () => context.go('/coaches'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.assignment_rounded,
                              label: 'Profiles',
                              color: const Color(0xFFE91E63), // Pink accent for Templates
                              onTap: () => context.go(AppRoutes.templateList),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Unable to load data', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.refresh(supervisorStatsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────── Supporting Sub-Widgets ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: Color(0xFF3D5AFE),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String name;
  final String coach;
  final int score;
  final String badge;
  final Color badgeColor;

  const _AlertCard({
    required this.name,
    required this.coach,
    required this.score,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded, color: badgeColor, size: 16),
              ),
            ],
          ),
          Text(coach, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score%',
                style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1A1A1A);
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: c.withOpacity(0.4), size: 20),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    );
  }
}
