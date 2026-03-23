import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import 'qc_audit_entity.dart';
import 'qc_provider.dart';

final auditHistoryProvider = FutureProvider<List<QcAuditEntity>>((ref) async {
  final repo = ref.watch(qcRepositoryProvider);
  final result = await repo.getAuditHistory(); // I need to add this to repo
  return result.fold(
    (failure) => throw failure.message,
    (audits) => audits,
  );
});

class QcAuditHistoryScreen extends ConsumerWidget {
  final bool hideAppBar;
  const QcAuditHistoryScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(auditHistoryProvider);

    final content = historyAsync.when(
      data: (audits) => audits.isEmpty
          ? const Center(child: Text('No audit history found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: audits.length,
              itemBuilder: (context, index) {
                final audit = audits[index];
                final color = _getStatusColor(audit.status);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(_getStatusIcon(audit.status), color: color, size: 20),
                    ),
                    title: Text(audit.targetName ?? '${audit.targetType.name.toUpperCase()} Audit'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${audit.status.name.replaceAll("_", " ").toUpperCase()}', 
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Audited: ${DateFormat('MMM dd, yyyy').format(audit.createdAt)}', 
                          style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.qcDetail.replaceAll(':id', audit.id)),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );

    if (hideAppBar) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Audit History')),
      body: content,
    );
  }

  Color _getStatusColor(QcAuditStatus status) {
    switch (status) {
      case QcAuditStatus.passed: return Colors.green;
      case QcAuditStatus.failed: return Colors.red;
      case QcAuditStatus.correction_requested: return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(QcAuditStatus status) {
    switch (status) {
      case QcAuditStatus.passed: return Icons.check_circle;
      case QcAuditStatus.failed: return Icons.cancel;
      case QcAuditStatus.correction_requested: return Icons.assignment_return;
      default: return Icons.help_outline;
    }
  }
}
