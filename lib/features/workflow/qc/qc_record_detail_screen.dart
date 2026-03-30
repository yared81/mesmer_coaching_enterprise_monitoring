import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'qc_audit_entity.dart';
import 'qc_provider.dart';
import '../enterprise/enterprise_provider.dart';
import '../coaching/coaching_provider.dart';
import '../../../core/router/app_routes.dart';
import '../enterprise/enterprise_document_provider.dart';
import '../enterprise/enterprise_document_entity.dart';
import '../../../core/constants/api_constants.dart';
import '../diagnosis/diagnosis_provider.dart';

class QcRecordDetailScreen extends ConsumerWidget {
  final String auditId;
  const QcRecordDetailScreen({super.key, required this.auditId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(qcAuditProvider(auditId));
    
    return auditAsync.when(
      data: (audit) {
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
                const Divider(height: 40),
                const Text('Evidence & Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildEvidenceSection(ref, audit),
                const Divider(height: 40),
                _buildVerificationChecklist(),
                const Divider(height: 40),
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
        color: audit.isRandomSample == true ? Colors.blue[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: audit.isRandomSample == true ? Colors.blue[200]! : Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                audit.isRandomSample == true ? Icons.casino_outlined : Icons.report_problem_rounded,
                color: audit.isRandomSample == true ? Colors.blue : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                audit.isRandomSample == true ? 'Random Statistical Sample' : 'Priority Risk Flag',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: audit.isRandomSample == true ? Colors.blue[800] : Colors.red[800],
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
            _dataItem('Sector', ent.sector.name),
            _dataItem('Employees', ent.employeeCount.toString()),
            _dataItem('Baseline Revenue', '${ent.baselineRevenue} ETB'),
            _dataItem('Location', ent.location),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Failed to load enterprise data: $e'),
      );
    } else {
      final sessionAsync = ref.watch(coachingSessionProvider(audit.targetId));
      final reportAsync = ref.watch(existingDiagnosisReportProvider(audit.targetId));
      
      return sessionAsync.when(
        data: (session) => session == null ? const Text('Session not found.') : Column(
          children: [
            _dataItem('Session Title', session.title),
            _dataItem('Session #', session.sessionNumber.toString()),
            _dataItem('Type', session.followupType.name),
            _dataItem('Status', session.status.name),
            if (session.revenueGrowthPercent != 0.0)
              _dataItem('Revenue Growth', '${session.revenueGrowthPercent}%'),
            if (session.currentEmployees != 0)
              _dataItem('Current Employees', session.currentEmployees.toString()),
              
            reportAsync.when(
              data: (report) => report == null ? const SizedBox() : Column(
                children: [
                  const Divider(height: 16),
                  _dataItem('Diagnosis Score', '${report['total_score']} / 5.0'),
                  _dataItem('Health %', '${report['health_percentage']}%'),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 8),
            Text('Scheduled: ${session.scheduledDate.toLocal()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    if (audit.status != QcAuditStatus.pending) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: audit.status == QcAuditStatus.passed ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: audit.status == QcAuditStatus.passed ? Colors.green[200]! : Colors.red[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  audit.status == QcAuditStatus.passed ? Icons.check_circle : Icons.cancel,
                  color: audit.status == QcAuditStatus.passed ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Text(
                  'AUDIT ${audit.status.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: audit.status == QcAuditStatus.passed ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
            if (audit.auditorComments != null && audit.auditorComments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Auditor Comments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(audit.auditorComments!, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      );
    }

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
                icon: const Icon(Icons.error_outline, color: Colors.white),
                label: const Text('FAIL', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submit(context, ref, audit.id, QcAuditStatus.correction_requested, commentController.text),
                icon: const Icon(Icons.assignment_return_outlined, color: Colors.white),
                label: const Text('CORRECTION', style: TextStyle(color: Colors.white, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submit(context, ref, audit.id, QcAuditStatus.passed, commentController.text),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('PASS', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(WidgetRef ref, QcAuditEntity audit) {
    final docsAsync = audit.targetType == QcTargetType.baseline 
      ? ref.watch(enterpriseDocumentsProvider(audit.targetId))
      : ref.watch(sessionDocumentsProvider(audit.targetId));

    return docsAsync.when(
      data: (docs) => docs.isEmpty 
        ? const Center(child: Text('No evidence uploaded.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final fullUrl = '${ApiConstants.baseUrl}${doc.fileUrl}';
              return GestureDetector(
                onTap: () => _showImageDialog(context, fullUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading evidence: $e'),
    );
  }

  Widget _buildVerificationChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Self-Verification Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _checkItem('All photos match business description'),
        _checkItem('GPS coordinates are within expected range'),
        _checkItem('Owner info matches ID/License'),
        _checkItem('Revenue data is plausible for sector'),
      ],
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref, String auditId, QcAuditStatus status, String comment) async {
    if ((status == QcAuditStatus.failed || status == QcAuditStatus.correction_requested) && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reason for ${status.name} is required.')));
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
