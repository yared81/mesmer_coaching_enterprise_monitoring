import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'qc_audit_entity.dart';
import 'qc_provider.dart';

class QcDashboardScreen extends ConsumerWidget {
  const QcDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditsAsync = ref.watch(pendingAuditsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QC Verification Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.pushNamed(context, '/qc/history'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pendingAuditsProvider.notifier).fetch(),
          ),
        ],
      ),
      body: auditsAsync.when(
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
                      title: Text('${audit.targetType.name.toUpperCase()} Audit'),
                      subtitle: Text('ID: ${audit.targetId.substring(0, 8)}... | ${audit.isRandomSample ? "Random Sample" : "Triggered Flag"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showReviewDialog(context, ref, audit),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, QcAuditEntity audit) {
    final commentController = TextEditingController();
    QcAuditStatus selectedStatus = QcAuditStatus.passed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Review ${audit.targetType.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Evaluate the quality of this record based on the evidence provided.'),
                const SizedBox(height: 20),
                DropdownButtonFormField<QcAuditStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Verdict'),
                  items: [
                    const DropdownMenuItem(value: QcAuditStatus.passed, child: Text('PASS')),
                    const DropdownMenuItem(value: QcAuditStatus.failed, child: Text('FAIL')),
                  ],
                  onChanged: (val) => setState(() => selectedStatus = val!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Auditor Comments',
                    hintText: 'Required if failed...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedStatus == QcAuditStatus.passed ? Colors.green : Colors.red,
              ),
              onPressed: () async {
                if (selectedStatus == QcAuditStatus.failed && commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide comments for failures.')),
                  );
                  return;
                }
                
                try {
                  await ref.read(pendingAuditsProvider.notifier).review(
                    audit.id, 
                    selectedStatus, 
                    commentController.text
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted successfully.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('SUBMIT VERDICT', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
