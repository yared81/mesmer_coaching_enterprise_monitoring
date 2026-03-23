import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'qc_audit_entity.dart';
import 'qc_provider.dart';
import '../../../core/router/app_routes.dart';

class QcDashboardScreen extends ConsumerWidget {
  final bool hideAppBar;
  const QcDashboardScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditsAsync = ref.watch(pendingAuditsProvider);

    final content = auditsAsync.when(
        data: (audits) => audits.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green[200]),
                    const SizedBox(height: 16),
                    const Text('No pending audits! Everything is verified.', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: audits.length,
                itemBuilder: (context, index) {
                  final audit = audits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: audit.targetType == QcTargetType.baseline 
                          ? Colors.blue[100] : Colors.orange[100],
                        child: Icon(
                          audit.targetType == QcTargetType.baseline ? Icons.business : Icons.event_note,
                          color: audit.targetType == QcTargetType.baseline ? Colors.blue : Colors.orange,
                        ),
                      ),
                      title: Text(audit.targetName ?? '${audit.targetType.name.toUpperCase()} Audit'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${audit.targetId.substring(0, 8)}...'),
                          if (audit.flagReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    audit.isRandomSample ? Icons.casino_outlined : Icons.report_problem_rounded,
                                    size: 14,
                                    color: audit.isRandomSample ? Colors.blue : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      audit.flagReason!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: audit.isRandomSample ? Colors.blue : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(AppRoutes.qcDetail.replaceAll(':id', audit.id)),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );

    if (hideAppBar) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QC Verification Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pendingAuditsProvider.notifier).fetch(),
          ),
        ],
      ),
      body: content,
    );
  }


}
