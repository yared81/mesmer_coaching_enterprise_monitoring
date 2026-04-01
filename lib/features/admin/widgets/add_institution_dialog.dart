import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/admin/institution_model.dart';
import 'package:mesmer_digital_coaching/features/admin/user_management_provider.dart';

class AddInstitutionDialog extends ConsumerStatefulWidget {
  final InstitutionModel? institution;
  final String? parentId;
  const AddInstitutionDialog({super.key, this.institution, this.parentId});

  @override
  ConsumerState<AddInstitutionDialog> createState() => _AddInstitutionDialogState();
}

class _AddInstitutionDialogState extends ConsumerState<AddInstitutionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _regionController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.institution?.name ?? '');
    _regionController = TextEditingController(text: widget.institution?.region ?? '');
    _emailController = TextEditingController(text: widget.institution?.contactEmail ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(userManagementActionProvider);

    return AlertDialog(
      title: Text(widget.institution == null ? (widget.parentId == null ? 'Add Organization' : 'Add Branch') : 'Edit Institution'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Institution Name'),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(labelText: 'Region/Location'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Contact Email'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: actionState.isLoading ? null : _submit,
          child: actionState.isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator()) : const Text('Save'),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text,
      'region': _regionController.text,
      'contact_email': _emailController.text,
      'parent_id': widget.parentId ?? widget.institution?.parentId,
    };

    if (widget.institution == null) {
      await ref.read(userManagementActionProvider.notifier).createInstitution(data);
    } else {
      await ref.read(userManagementActionProvider.notifier).updateInstitution(widget.institution!.id, data);
    }

    if (!mounted) return;
    if (ref.read(userManagementActionProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(userManagementActionProvider).error.toString())),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
