import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/institution_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/widgets/add_institution_dialog.dart';

class InstitutionManagementScreen extends ConsumerWidget {
  const InstitutionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch only root institutions (parent_id is null)
    final rootsAsync = ref.watch(institutionsListProvider('root'));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Organizations & Branches'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: rootsAsync.when(
        data: (roots) => _buildRootList(context, ref, roots),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRootList(BuildContext context, WidgetRef ref, List<InstitutionModel> roots) {
    if (roots.isEmpty) {
      return const Center(child: Text('No organizations registered.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final root = roots[index];
        return _InstitutionTile(institution: root);
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddInstitutionDialog(),
    );
  }
}

class _InstitutionTile extends ConsumerWidget {
  final InstitutionModel institution;
  const _InstitutionTile({required this.institution});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(institutionsListProvider('parentId=${institution.id}'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.business, color: Colors.blue),
        title: Text(institution.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(institution.region ?? 'Global', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildKpiBadge('Active', Colors.green),
                const SizedBox(width: 8),
                _buildKpiBadge('92% Health', Colors.blue),
                const SizedBox(width: 8),
                _buildKpiBadge('15 Branches', Colors.orange),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () => _showAddBranchDialog(context, institution.id),
        ),
        children: [
          branchesAsync.when(
            data: (branches) => branches.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: Text('No branches found.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)))
                : Column(
                    children: branches.map((b) => ListTile(
                      contentPadding: const EdgeInsets.only(left: 48, right: 16),
                      leading: const Icon(Icons.account_tree, size: 16, color: Colors.grey),
                      title: Text(b.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(b.contactEmail ?? '', style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _showEditDialog(context, b),
                      ),
                    )).toList(),
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  void _showAddBranchDialog(BuildContext context, String parentId) {
    showDialog(
      context: context,
      builder: (context) => AddInstitutionDialog(parentId: parentId),
    );
  }

  void _showEditDialog(BuildContext context, InstitutionModel inst) {
    showDialog(
      context: context,
      builder: (context) => AddInstitutionDialog(institution: inst),
    );
  }

  Widget _buildKpiBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

