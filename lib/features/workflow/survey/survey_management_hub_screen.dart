import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_template_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';

class SurveyManagementHubScreen extends ConsumerWidget {
  const SurveyManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allTemplatesProvider);
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? UserRole.stakeholder;

    // Determine permitted survey types dynamically
    final List<Map<String, String>> surveyTypes = [
      {'code': 'baseline', 'label': 'Baseline'},
      {'code': 'midline', 'label': 'Midline'},
      {'code': 'endline', 'label': 'Endline'},
      {'code': 'training', 'label': 'Training'},
    ];

    // Optional: Add filtering logic here if some roles should only see specific types
    // For now, all roles allowed in SurveyHub (superAdmin, programManager, meOfficer) can see all.
    final filteredTypes = surveyTypes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Survey Management Hub'),
        backgroundColor: const Color(0xFF311B92),
        foregroundColor: Colors.white,
        actions: [
          if (role == UserRole.superAdmin || role == UserRole.programManager || role == UserRole.meOfficer)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => context.push(AppRoutes.templateBuilder),
            ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) => DefaultTabController(
          length: filteredTypes.length,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: const Color(0xFF311B92),
                  indicatorColor: const Color(0xFF311B92),
                  isScrollable: true,
                  tabs: filteredTypes.map((t) => Tab(text: t['label'])).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: filteredTypes.map((t) => _buildTemplateList(context, templates, t['code']!)).toList(),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTemplateList(BuildContext context, List<DiagnosisTemplateEntity> templates, String type) {
    final filtered = templates.where((t) => t.templateTypeCode == type).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No $type surveys found.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final template = filtered[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(template.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Version: ${template.version} | ${template.categories.length} Sections'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: template.isActive ? Colors.green[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    template.isActive ? 'ACTIVE' : 'DRAFT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: template.isActive ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Template')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                const PopupMenuItem(value: 'export', child: Text('Export JSON')),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  context.push(AppRoutes.templateBuilder, extra: template);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
