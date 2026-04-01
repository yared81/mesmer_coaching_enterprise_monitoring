import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_provider.dart';
import 'package:mesmer_digital_coaching/features/dashboard/stat_card.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/features/dashboard/activity_feed_widget.dart';
import 'package:mesmer_digital_coaching/features/dashboard/app_search_bar.dart';
import 'package:mesmer_digital_coaching/features/dashboard/widgets/program_funnel_widget.dart';
import 'package:mesmer_digital_coaching/features/dashboard/widgets/regional_performance_widget.dart';
import 'package:mesmer_digital_coaching/core/widgets/notification_bell.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const NotificationBell(),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Statistics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.05,
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
                      const ProgramFunnelWidget(),
                      const SizedBox(height: 32),
                      const RegionalPerformanceWidget(),
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

