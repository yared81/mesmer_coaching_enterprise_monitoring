import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'graduation_provider.dart';
import 'enterprise_provider.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';

const _kMinSessions = 8;

class GraduationHubScreen extends ConsumerWidget {
  const GraduationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyListAsync = ref.watch(graduationReadyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graduation Hub'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: readyListAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 16),
                  Text('No enterprises ready for graduation.',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(graduationReadyListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final completedCount = item['completedCount'] as int? ?? 0;
                final hasBaseline = item['has_baseline'] as bool? ?? false;
                final hasEvidence = item['has_evidence'] as bool? ?? false;
                final checklistPassed =
                    completedCount >= _kMinSessions && hasBaseline;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: checklistPassed
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['business_name'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _statusBadge(checklistPassed),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Owner: ${item['owner_name'] ?? "N/A"}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 12),

                        // Checklist
                        _checkRow('Baseline assessment submitted', hasBaseline),
                        _checkRow(
                            'Min $_kMinSessions sessions completed ($completedCount recorded)',
                            completedCount >= _kMinSessions),
                        _checkRow('Evidence attached', hasEvidence),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context
                                  .push('/enterprises/detail/${item['id']}'),
                              child: const Text('View Profile'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: checklistPassed
                                    ? Colors.green
                                    : Theme.of(context).disabledColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              onPressed: checklistPassed
                                  ? () => _approveGraduation(
                                      context, ref, item['id'],
                                      completedCount: completedCount,
                                      hasBaseline: hasBaseline,
                                      hasEvidence: hasEvidence)
                                  : () => _showChecklistBlockedDialog(
                                      context,
                                      completedCount: completedCount,
                                      hasBaseline: hasBaseline,
                                      hasEvidence: hasEvidence),
                              icon: Icon(
                                  checklistPassed
                                      ? Icons.check_circle_outline
                                      : Icons.lock_outline,
                                  size: 18),
                              label: Text(
                                  checklistPassed ? 'Approve' : 'Locked'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading data: $error')),
      ),
    );
  }

  Widget _statusBadge(bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: passed
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        passed ? 'Ready' : 'Incomplete',
        style: TextStyle(
          color: passed ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _checkRow(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: passed ? Colors.green : Colors.red[300],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: passed ? null : Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showChecklistBlockedDialog(
    BuildContext context, {
    required int completedCount,
    required bool hasBaseline,
    required bool hasEvidence,
  }) {
    final missing = <String>[];
    if (!hasBaseline) missing.add('Baseline assessment not submitted');
    if (completedCount < _kMinSessions)
      missing.add(
          'Only $completedCount of $_kMinSessions required sessions completed');
    if (!hasEvidence) missing.add('No evidence attached to coaching sessions');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Graduation Locked'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'The following requirements must be met before graduation can be approved:',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            ...missing.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel_rounded,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(m,
                              style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _approveGraduation(
    BuildContext context,
    WidgetRef ref,
    String enterpriseId, {
    required int completedCount,
    required bool hasBaseline,
    required bool hasEvidence,
  }) async {
    // Final server-side guard — double check before showing confirm dialog
    if (completedCount < _kMinSessions || !hasBaseline) {
      _showChecklistBlockedDialog(context,
          completedCount: completedCount,
          hasBaseline: hasBaseline,
          hasEvidence: hasEvidence);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Graduation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'All requirements have been verified. This will officially graduate the enterprise and generate a certificate.'),
            const SizedBox(height: 12),
            _checkRow('Baseline submitted', hasBaseline),
            _checkRow('$completedCount sessions completed', true),
            _checkRow('Evidence attached', hasEvidence),
            const SizedBox(height: 8),
            const Text('This action cannot be undone.',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve Graduation'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(graduationRepositoryProvider);
        final result = await repo.requestGraduation(enterpriseId);
        result.fold(
          (failure) {
            if (context.mounted)
              CustomToaster.show(
                  context: context,
                  message: failure.message,
                  isError: true);
          },
          (data) {
            if (context.mounted)
              CustomToaster.show(
                  context: context,
                  message: '🎓 Graduation approved! Certificate generated.');
            ref.invalidate(graduationReadyListProvider);
            ref.invalidate(enterpriseDetailProvider(enterpriseId));
            ref.invalidate(enterpriseListProvider);
          },
        );
      } catch (e) {
        if (context.mounted)
          CustomToaster.show(
              context: context,
              message: 'Unexpected Error: $e',
              isError: true);
      }
    }
  }
}
