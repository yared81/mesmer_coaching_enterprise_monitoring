import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'qc_audit_entity.dart';
import 'qc_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coach_session_provider.dart';

class QcRecordDetailScreen extends ConsumerWidget {
  final String auditId;
  const QcRecordDetailScreen({super.key, required this.auditId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditsAsync = ref.watch(pendingAuditsProvider);
    
    return auditsAsync.when(
      data: (audits) {
        final audit = audits.firstWhere((a) => a.id == auditId, orElse: () => throw Exception('Audit not found'));
        return Scaffold(
          appBar: AppBar(
            title: Text('${audit.targetType.name.toUpperCase()} Review'),
            backgroundColor: audit.targetType == QcTargetType.baseline ? Colors.blue : Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuditInfo(audit),
                const Divider(height: 40),
                const Text('Parent Record Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTargetData(ref, audit),
                const SizedBox(height: 40),
                _buildVerdictSection(context, ref, audit),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildAuditInfo(QcAuditEntity audit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: audit.isRandomSample ? Colors.blue[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: audit.isRandomSample ? Colors.blue[200]! : Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                audit.isRandomSample ? Icons.casino_outlined : Icons.report_problem_rounded,
                color: audit.isRandomSample ? Colors.blue : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                audit.isRandomSample ? 'Random Statistical Sample' : 'Priority Risk Flag',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: audit.isRandomSample ? Colors.blue[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(audit.flagReason ?? 'No specific flags.', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTargetData(WidgetRef ref, QcAuditEntity audit) {
    if (audit.targetType == QcTargetType.baseline) {
      final enterpriseAsync = ref.watch(enterpriseDetailProvider(audit.targetId));
      return enterpriseAsync.when(
        data: (ent) => Column(
          children: [
            _dataItem('Business Name', ent.businessName),
            _dataItem('Owner', ent.ownerName),
            _dataItem('Sector', ent.sector),
            _dataItem('Employees', ent.employeeCount.toString()),
            _dataItem('Annual Revenue', '${ent.annualRevenue} ETB'),
            _dataItem('Location', ent.locationName),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Failed to load enterprise data: $e'),
      );
    } else {
      final sessionAsync = ref.watch(coachingSessionProvider(audit.targetId));
      return sessionAsync.when(
        data: (session) => session == null ? const Text('Session not found.') : Column(
          children: [
            _dataItem('Session Title', session.title),
            _dataItem('Session #', session.sessionNumber.toString()),
            _dataItem('Type', session.followupType),
            _dataItem('Status', session.status),
            if (session.revenueGrowthPercent != null)
              _dataItem('Revenue Growth', '${session.revenueGrowthPercent}%'),
            if (session.currentEmployees != null)
              _dataItem('Current Employees', session.currentEmployees.toString()),
            const SizedBox(height: 8),
            Text('Scheduled: ${session.scheduledDate}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Failed to load session data: $e'),
      );
    }
  }

  Widget _dataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVerdictSection(BuildContext context, WidgetRef ref, QcAuditEntity audit) {
    final commentController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Final Verdict', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Auditor Comments / Feedback',
            border: OutlineInputBorder(),
            hintText: 'Describe any issues or confirm quality...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submit(context, ref, audit.id, QcAuditStatus.failed, commentController.text),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('REJECT / FAIL', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submit(context, ref, audit.id, QcAuditStatus.passed, commentController.text),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('APPROVE / PASS', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref, String auditId, QcAuditStatus status, String comment) async {
    if (status == QcAuditStatus.failed && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason for failure is required.')));
      return;
    }
    
    try {
      await ref.read(pendingAuditsProvider.notifier).review(auditId, status, comment);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
