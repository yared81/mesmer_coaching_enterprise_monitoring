import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'diagnosis_provider.dart';

class AssessmentProfileListScreen extends ConsumerWidget {
  const AssessmentProfileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Assessment Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allTemplatesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _AssessmentProfileCard(
                  title: template.title,
                  isActive: template.isActive,
                  date: template.updatedAt ?? DateTime.now(),
                  onTap: () => context.push(AppRoutes.templateBuilder, extra: template),
                  onDelete: () => _confirmDeleteProfile(context, ref, template.id, template.title),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Failed to load templates: $err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.templateBuilder),
        backgroundColor: const Color(0xFFE91E63),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_rounded, size: 64, color: Color(0xFFE91E63)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Assessment Profiles Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first assessment profile to allow\ncoaches to assess enterprises.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.templateBuilder),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(BuildContext context, WidgetRef ref, String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment Profile?'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final repository = ref.read(diagnosisRepositoryProvider);
              final result = await repository.deleteTemplate(id);
              
              if (context.mounted) {
                result.fold(
                  (failure) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: ${failure.message}'), backgroundColor: Colors.red),
                  ),
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile deleted successfully'), backgroundColor: Colors.green),
                    );
                    ref.invalidate(allTemplatesProvider);
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

class _AssessmentProfileCard extends StatelessWidget {
  final String title;
  final bool isActive;
  final DateTime date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AssessmentProfileCard({
    required this.title,
    required this.isActive,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: const Color(0xFF00B09B), width: 1.5) : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00B09B).withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.article_rounded,
            color: isActive ? const Color(0xFF00B09B) : Colors.grey[500],
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              if (isActive) ...[
                const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF00B09B)),
                const SizedBox(width: 4),
                const Text('Active', style: TextStyle(color: Color(0xFF00B09B), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 12),
              ],
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
            onPressed: onDelete,
            tooltip: 'Delete Profile',
          ),
          ), // ListTile
        ), // InkWell
      ), // Material
    ); // Container
  }
}
