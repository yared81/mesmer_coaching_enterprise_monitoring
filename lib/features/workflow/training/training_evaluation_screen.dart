import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_entity.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_repository.dart';

class TrainingEvaluationScreen extends ConsumerStatefulWidget {
  final String trainingId;
  final String enterpriseId;
  const TrainingEvaluationScreen({
    super.key, 
    required this.trainingId, 
    required this.enterpriseId,
  });

  @override
  ConsumerState<TrainingEvaluationScreen> createState() => _TrainingEvaluationScreenState();
}

class _TrainingEvaluationScreenState extends ConsumerState<TrainingEvaluationScreen> {
  int _relevance = 5;
  int _content = 5;
  int _trainer = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    
    final evaluationData = {
      'relevance': _relevance,
      'content': _content,
      'trainer': _trainer,
      'comment': _commentController.text,
    };

    final average = ((_relevance + _content + _trainer) / 3).round();

    final result = await ref.read(trainingRepositoryProvider).submitFeedback(
      widget.trainingId, 
      widget.enterpriseId, 
      average, 
      evaluationData,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workshop Evaluation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your feedback helps us improve future workshops.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildRatingSection('Relevance', 'How relevant was this training to your business?', _relevance, (v) => setState(() => _relevance = v)),
            const Divider(height: 48),
            _buildRatingSection('Content Quality', 'How would you rate the training materials and content?', _content, (v) => setState(() => _content = v)),
            const Divider(height: 48),
            _buildRatingSection('Trainer Facilitation', 'How effective was the trainer in delivering the session?', _trainer, (v) => setState(() => _trainer = v)),
            const SizedBox(height: 32),
            const Text('Additional Comments', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Anything else you would like to share...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(String title, String subtitle, int current, Function(int) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = value <= current;
            return InkWell(
              onTap: () => onSelected(value),
              child: Column(
                children: [
                  Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? Colors.amber : Colors.grey[300],
                    size: 40,
                  ),
                  const SizedBox(height: 4),
                  Text('$value', style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
