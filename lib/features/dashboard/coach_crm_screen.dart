import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'activity_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

class CoachCrmScreen extends ConsumerWidget {
  const CoachCrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(coachPortfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Enterprise Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(coachPortfolioProvider),
          ),
        ],
      ),
      body: portfolioAsync.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No enterprises assigned yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (ctx, i) => _EnterprisePortfolioCard(item: items[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _EnterprisePortfolioCard extends StatelessWidget {
  final CoachPortfolioItem item;
  const _EnterprisePortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(item.sector,
                      style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.businessName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${item.ownerName} · ${item.location}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),

            const Divider(height: 20),

            // ── IAP Progress ─────────────────────────────────────────
            Row(
              children: [
                // Progress ring
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: item.iapTotal == 0
                            ? 0
                            : item.iapCompleted / item.iapTotal,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.green,
                        strokeWidth: 5,
                      ),
                      Text('${item.iapPercentage}%',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IAP Tasks',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      _statBadge('✅ ${item.iapCompleted}', Colors.green),
                      const SizedBox(width: 6),
                      _statBadge(
                          '${item.iapTotal - item.iapCompleted} left',
                          Colors.orange),
                      if (item.iapOverdue > 0) ...[
                        const SizedBox(width: 6),
                        _statBadge('⚠️ ${item.iapOverdue}', Colors.red),
                      ],
                    ]),
                  ],
                ),
                const Spacer(),
                if (item.lastActivity != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Last activity',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(
                        DateFormat('MMM dd').format(item.lastActivity!),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'stalled': return Colors.orange;
      case 'graduated': return Colors.blue;
      case 'dropped': return Colors.red;
      default: return Colors.grey;
    }
  }
}
