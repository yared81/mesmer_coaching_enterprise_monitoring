import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/features/admin/institution_model.dart';

final institutionsProvider = FutureProvider<List<InstitutionModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/v1/users/institutions');
  if (response.statusCode == 200) {
    final data = response.data['data'] as List;
    return data.map((json) => InstitutionModel.fromJson(json)).toList();
  }
  throw Exception('Failed to load institutions');
});

class InstitutionManagementScreen extends ConsumerWidget {
  const InstitutionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInst = ref.watch(institutionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Institutions & Branches'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: asyncInst.when(
        data: (institutions) {
          final roots = institutions.where((i) => i.parentId == null).toList();
          if (roots.isEmpty) {
            return const Center(child: Text('No institutions found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(institutionsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roots.length,
              itemBuilder: (context, index) {
                return _InstitutionNode(
                  institution: roots[index],
                  allInstitutions: institutions,
                  ref: ref,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInstitutionDialog(context, ref, null),
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddInstitutionDialog(BuildContext context, WidgetRef ref, String? parentId) async {
    final nameCtrl = TextEditingController();
    final regionCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? 'Add Root Institution' : 'Add Branch'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: regionCtrl,
                decoration: const InputDecoration(labelText: 'Region'),
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Contact Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final dio = ref.read(dioProvider);
        await dio.post('/api/v1/users/institutions', data: {
          'name': nameCtrl.text.trim(),
          'region': regionCtrl.text.trim(),
          'contact_email': emailCtrl.text.trim(),
          if (parentId != null) 'parent_id': parentId,
        });
        ref.invalidate(institutionsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institution created successfully.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

class _InstitutionNode extends StatelessWidget {
  final InstitutionModel institution;
  final List<InstitutionModel> allInstitutions;
  final WidgetRef ref;

  const _InstitutionNode({
    required this.institution, 
    required this.allInstitutions,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final children = allInstitutions.where((i) => i.parentId == institution.id).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(institution.parentId == null ? Icons.account_balance : Icons.account_tree, color: const Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Expanded(child: Text(institution.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        subtitle: Text('Region: ${institution.region ?? 'N/A'} | Branches: ${children.length}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                // To keep it simple, we recreate the dialog call here 
                // Normally this would be handled better but fits the UI structure.
                (context.findAncestorWidgetOfExactType<InstitutionManagementScreen>() as InstitutionManagementScreen?)
                  ?._showAddInstitutionDialog(context, ref, institution.id);
              },
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: children.map((child) => Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: _InstitutionNode(institution: child, allInstitutions: allInstitutions, ref: ref),
        )).toList(),
      ),
    );
  }
}
