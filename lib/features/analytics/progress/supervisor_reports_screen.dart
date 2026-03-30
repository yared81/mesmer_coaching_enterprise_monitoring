import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/stat_card.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'report_provider.dart';

class SupervisorReportsScreen extends ConsumerWidget {
  final bool hideAppBar;
  const SupervisorReportsScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    Widget body = enterprisesAsync.when(
      data: (enterprises) => _buildContent(context, ref, enterprises),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('$err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );

    if (hideAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MERL Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export System CSV',
            onPressed: () => _handleSystemExport(context, ref),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<dynamic> enterprises) {
    final total = enterprises.length;
    final active = enterprises.where((e) => (e as EnterpriseEntity).status == EnterpriseStatus.active).length;
    final stalled = enterprises.where((e) => (e as EnterpriseEntity).status == EnterpriseStatus.stalled).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary metric cards
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total',
                  value: '$total',
                  icon: Icons.business_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  title: 'Active',
                  value: '$active',
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  title: 'Stalled',
                  value: '$stalled',
                  icon: Icons.warning_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),

        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Enterprise Review',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleSystemExport(context, ref),
                icon: const Icon(Icons.download_rounded, size: 15),
                label: const Text('CSV', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),

        // Enterprise list - scrollable cards with review actions
        Expanded(
          child: enterprises.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No enterprises found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: enterprises.length,
                  itemBuilder: (context, i) {
                    final e = enterprises[i] as EnterpriseEntity;
                    return _EnterpriseReviewCard(
                      enterprise: e,
                      onExportPdf: () => _handlePdfExport(context, ref, e.id),
                      onViewSessions: () => context.go('/sessions?enterpriseId=${e.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handlePdfExport(BuildContext context, WidgetRef ref, String id) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF report...')),
      );
      await ref.read(reportDownloadProvider).downloadEnterprisePDF(id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _handleSystemExport(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting system CSV...')),
      );
      await ref.read(reportDownloadProvider).downloadSystemCSV();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

// ─── Enterprise Review Card ────────────────────────────────────────────────────

class _EnterpriseReviewCard extends StatelessWidget {
  final EnterpriseEntity enterprise;
  final VoidCallback onExportPdf;
  final VoidCallback onViewSessions;

  const _EnterpriseReviewCard({
    required this.enterprise,
    required this.onExportPdf,
    required this.onViewSessions,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(enterprise.status);
    final sectorLabel = enterprise.sector.name[0].toUpperCase() + enterprise.sector.name.substring(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onViewSessions,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Name + Status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      enterprise.businessName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: enterprise.status),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Sector + Owner + Employees
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(sectorLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 12),
                  Icon(Icons.person_outline, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      enterprise.ownerName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.group_outlined, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${enterprise.employeeCount} emp.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),

              // Baseline score if available
              if (enterprise.baselineScore != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Baseline Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      '${enterprise.baselineScore!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: enterprise.baselineScore! >= 60 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: enterprise.baselineScore! / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      enterprise.baselineScore! >= 60 ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],

              const Divider(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewSessions,
                      icon: const Icon(Icons.list_alt_rounded, size: 15),
                      label: const Text('Sessions', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onExportPdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
                      label: const Text('PDF Report', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: BorderSide(color: Colors.deepOrange.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(EnterpriseStatus status) {
    switch (status) {
      case EnterpriseStatus.active: return Colors.green;
      case EnterpriseStatus.stalled: return Colors.red;
      case EnterpriseStatus.pilot: return Colors.orange;
      case EnterpriseStatus.graduated: return Colors.blue;
      default: return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final EnterpriseStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case EnterpriseStatus.active: color = Colors.green; break;
      case EnterpriseStatus.stalled: color = Colors.red; break;
      case EnterpriseStatus.pilot: color = Colors.orange; break;
      case EnterpriseStatus.graduated: color = Colors.blue; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
