import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/domain/entities/coaching_session_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/providers/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/data/models/diagnosis_report_model.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/question_card.dart';
import 'diagnosis_summary_screen.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AssessmentScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(latestDiagnosisTemplateProvider);
    final sessionAsync = ref.watch(coachingSessionProvider(widget.sessionId));
    final existingReportAsync = ref.watch(existingDiagnosisReportProvider(widget.sessionId));
    final responseState = ref.watch(diagnosisStateProvider(widget.sessionId));

    // Listen for existing report and merge into state if found
    ref.listen(existingDiagnosisReportProvider(widget.sessionId), (previous, next) {
      next.whenData((report) {
        if (report != null && report['responses'] != null) {
          ref.read(diagnosisStateProvider(widget.sessionId).notifier)
              .mergeServerResponses(report['responses']);
        }
      });
    });

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return const Scaffold(body: Center(child: Text('Session not found')));
        }

        final isReadOnly = session.status == SessionStatus.completed || 
                           session.status == SessionStatus.cancelled;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Digital Diagnosis'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (!isReadOnly)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(latestDiagnosisTemplateProvider),
                ),
            ],
          ),
          body: Stack(
            children: [
              templateAsync.when(
                data: (template) {
                  final progress = responseState.getProgress(template);
                  final isComplete = responseState.isComplete(template);

                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(template, session, isReadOnly),
                          ),
                          ...template.categories.map((category) {
                            return SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    color: AppColors.background,
                                    child: Text(
                                      category.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return QuestionCard(
                                        sessionId: widget.sessionId,
                                        question: category.questions[index],
                                        readOnly: isReadOnly,
                                      );
                                    },
                                    childCount: category.questions.length,
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (!isReadOnly)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: ElevatedButton(
                                  onPressed: (isComplete && !responseState.isLoading) 
                                    ? () => _submit(template.id) 
                                    : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor: Colors.grey[300],
                                  ),
                                  child: Text(
                                    isComplete ? 'Submit Diagnosis' : 'Complete all questions to submit',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
                      // Progress HUD
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildProgressHUD(progress),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorState(err),
              ),
              // Submitting Overlay
              if (responseState.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Saving Diagnosis...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildHeader(dynamic template, CoachingSessionEntity session, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReadOnly)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This session is finalized. Diagnosis cannot be modified.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            template.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
              Text(
                'Session: ${session.title}',
                style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
        ],
      ),
    );
  }

  Widget _buildProgressHUD(double progress) {
    return Hero(
      tag: 'progress_hud',
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          const Text('Could not load diagnosis template'),
          Text(err.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(latestDiagnosisTemplateProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _submit(String templateId) async {
    final notifier = ref.read(diagnosisStateProvider(widget.sessionId).notifier);
    final repository = ref.read(diagnosisRepositoryProvider);

    final result = await notifier.submitDiagnosis(
      repository,
      templateId,
    );

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        if (failure.message.contains('409') || failure.message.toLowerCase().contains('structure has significantly changed')) {
          _showConflictDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit: ${failure.message}'), backgroundColor: AppColors.error),
          );
        }
      },
      (reportData) {
        final report = DiagnosisReportModel.fromJson(reportData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnosis submitted successfully!'), backgroundColor: AppColors.success),
        );
        
        // Navigate to Summary Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisSummaryScreen(report: report),
          ),
        );
      },
    );
  }

  void _showConflictDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assessment Updated'),
        content: const Text(
          'A supervisor has updated the structure of this assessment. '
          'We need to refresh the questions to ensure your answers match the new layout.\n\n'
          'Answers to unchanged questions will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.refresh(latestDiagnosisTemplateProvider);
            },
            child: const Text('REFRESH NOW'),
          ),
        ],
      ),
    );
  }
}
