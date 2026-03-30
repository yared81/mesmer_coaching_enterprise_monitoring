import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/widgets/add_user_dialog.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback if you need to access ref.read in initState
    // but better to just use listeners/watch or update filters on interactions.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter({String? role, String? institution, String? search}) {
    final currentFilters = ref.read(userFilterProvider);
    ref.read(userFilterProvider.notifier).state = (
      role: role ?? currentFilters.role,
      institution: institution ?? currentFilters.institution,
      search: search ?? currentFilters.search,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(userFilterProvider.notifier).state = (role: null, institution: null, search: null);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);
    final institutionsAsync = ref.watch(institutionsListProvider('all'));
    final currentFilters = ref.watch(userFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add User',
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(institutionsAsync, currentFilters),
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUserList(users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('$err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(usersListProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AsyncValue<List<dynamic>> institutionsAsync, ({String? role, String? institution, String? search}) filters) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateFilter(search: null);
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            onChanged: (val) {
              _updateFilter(search: val.isEmpty ? null : val);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          // Filter dropdowns
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleTab('All Roles', null, filters.role),
                      _buildRoleTab('Coaches', UserRole.coach.snakeCase, filters.role),
                      _buildRoleTab('Trainers', UserRole.trainer.snakeCase, filters.role),
                      _buildRoleTab('Verifiers', UserRole.dataVerifier.snakeCase, filters.role),
                      _buildRoleTab('Coordinators', UserRole.regionalCoordinator.snakeCase, filters.role),
                      _buildRoleTab('M&E Officers', UserRole.meOfficer.snakeCase, filters.role),
                      _buildRoleTab('Program Managers', UserRole.programManager.snakeCase, filters.role),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: institutionsAsync.when(
                  data: (institutions) => DropdownButtonFormField<String>(
                    value: filters.institution,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Institution',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('All Institutions')),
                      ...institutions.map<DropdownMenuItem<String>>((inst) {
                        return DropdownMenuItem(
                          value: inst.id,
                          child: Text(inst.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                        );
                      }),
                    ],
                    onChanged: (val) => _updateFilter(institution: val),
                  ),
                  loading: () => const TextField(
                    enabled: false,
                    decoration: InputDecoration(hintText: 'Loading...', isDense: true),
                  ),
                  error: (_, __) => const TextField(
                    enabled: false,
                    decoration: InputDecoration(hintText: 'Could not load institutions', isDense: true),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String label, String? roleValue, String? currentRole) {
    final isSelected = currentRole == roleValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _updateFilter(role: roleValue);
          } else if (roleValue != null) { // Unselecting a specific role goes back to "All Roles"
            _updateFilter(role: null);
          }
        },
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No users found matching your filters.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        final roleColor = _getRoleColor(user.role);
        final roleLabel = (user.role as UserRole).name.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (m) => ' ${m.group(0)}',
        ).trim();

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar - Slightly smaller to save vertical space
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.12),
                  radius: 20,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Use a Wrap for badges to avoid horizontal overflow if both are long
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: roleColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              roleLabel.toUpperCase(),
                              style: TextStyle(fontSize: 9, color: roleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                color: user.isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (user.institutionName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                              ),
                              child: Text(
                                user.institutionName!.toUpperCase(),
                                style: const TextStyle(fontSize: 9, color: Colors.indigo, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return Colors.red;
      case UserRole.programManager: return Colors.deepOrange;
      case UserRole.coach: return Colors.blue;
      case UserRole.trainer: return Colors.teal;
      case UserRole.regionalCoordinator: return Colors.purple;
      case UserRole.meOfficer: return Colors.indigo;
      case UserRole.dataVerifier: return Colors.cyan;
      default: return Colors.grey;
    }
  }

  void _showAddUserDialog(BuildContext context, {dynamic user}) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(user: user),
    );
  }
}
