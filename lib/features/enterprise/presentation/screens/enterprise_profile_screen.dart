import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/enterprise_provider.dart';
import 'enterprise_detail_screen.dart';

/// Enterprise self profile wrapper.
/// Loads the enterprise id from enterprise dashboard stats and then shows the same
/// profile/overview screen used by coaches and supervisors.
class EnterpriseProfileScreen extends ConsumerWidget {
  const EnterpriseProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(enterpriseDashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (stats) {
        if (stats.enterpriseId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Enterprise profile not linked.')));
        }
        return EnterpriseDetailScreen(enterpriseId: stats.enterpriseId);
      },
    );
  }
}

