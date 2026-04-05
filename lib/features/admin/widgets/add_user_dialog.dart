import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'package:mesmer_digital_coaching/features/admin/user_management_provider.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  final dynamic user;
  const AddUserDialog({super.key, this.user});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  UserRole? _selectedRole;
  String? _selectedInstitution;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _selectedRole = widget.user?.role;
    _selectedInstitution = widget.user?.institutionId;
  }

  @override
  Widget build(BuildContext context) {
    final institutionsAsync = ref.watch(institutionsListProvider('all'));
    final actionState = ref.watch(userManagementActionProvider);

    return AlertDialog(
      title: Text(widget.user == null ? 'Add New User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (v) => v!.isEmpty ? 'Email is required' : null,
              ),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Password must be at least 6 chars' : null,
                ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role.toString().split('.').last.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
                validator: (v) => v == null ? 'Role is required' : null,
              ),
              const SizedBox(height: 16),
              institutionsAsync.when(
                data: (institutions) => DropdownButtonFormField<String>(
                  value: _selectedInstitution,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Institution'),
                  items: institutions.map((inst) {
                    return DropdownMenuItem(
                      value: inst.id,
                      child: Text(inst.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedInstitution = val),
                  validator: (v) => v == null ? 'Institution is required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => const Text('Error loading institutions'),
              ),
            ],
          ),
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
      'email': _emailController.text,
      'role': _selectedRole?.snakeCase,
      'institution_id': _selectedInstitution,
      if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text,
    };

    if (widget.user == null) {
      data['password'] = _passwordController.text;
      await ref.read(userManagementActionProvider.notifier).createUser(data);
    } else {
      await ref.read(userManagementActionProvider.notifier).updateUser(widget.user.id, data);
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
