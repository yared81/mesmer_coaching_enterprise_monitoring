import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/widgets/add_user_dialog.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String? _selectedRole;
  String? _selectedInstitution;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider({
      'role': _selectedRole,
      'institution_id': _selectedInstitution,
      'search': _searchController.text.isEmpty ? null : _searchController.text,
    }));

    final institutionsAsync = ref.watch(institutionsListProvider(const {}));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(institutionsAsync),
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUserList(users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AsyncValue<List<dynamic>> institutionsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role.toString().split('.').last,
                      child: Text(role.toString().split('.').last.toUpperCase()),
                    );
                  }).toList() + [const DropdownMenuItem(value: null, child: Text('ALL ROLES'))],
                  onChanged: (val) => setState(() => _selectedRole = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: institutionsAsync.when(
                  data: (institutions) => DropdownButtonFormField<String>(
                    value: _selectedInstitution,
                    decoration: const InputDecoration(labelText: 'Institution', border: OutlineInputBorder()),
                    items: institutions.map<DropdownMenuItem<String>>((inst) {
                      return DropdownMenuItem(value: inst.id, child: Text(inst.name));
                    }).toList() + [const DropdownMenuItem(value: null, child: Text('ALL INSTITUTIONS'))],
                    onChanged: (val) => setState(() => _selectedInstitution = val),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => const Text('Error loading institutions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found matching your filters.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              child: Icon(Icons.person, color: _getRoleColor(user.role)),
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12)),
                Text('${user.role.toString().split('.').last.toUpperCase()} | ${user.institutionName ?? "Global"}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  _showAddUserDialog(context, user: user);
                } else if (val == 'toggle') {
                  ref.read(userManagementActionProvider.notifier).toggleStatus(user.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                const PopupMenuItem(value: 'toggle', child: Text('Toggle Active/Inactive')),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return Colors.red;
      case UserRole.coach:
        return Colors.blue;
      case UserRole.trainer:
        return Colors.orange;
      case UserRole.supervisor:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddUserDialog(BuildContext context, {dynamic user}) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(user: user),
    );
  }
}
