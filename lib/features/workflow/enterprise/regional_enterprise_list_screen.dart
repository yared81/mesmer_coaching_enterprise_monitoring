import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_card.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_provider.dart';

class RegionalEnterpriseListScreen extends ConsumerStatefulWidget {
  const RegionalEnterpriseListScreen({super.key});

  @override
  ConsumerState<RegionalEnterpriseListScreen> createState() => _RegionalEnterpriseListScreenState();
}

class _RegionalEnterpriseListScreenState extends ConsumerState<RegionalEnterpriseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedCoachId;

  @override
  void initState() {
    super.initState();
    // Fetch initial list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEnterprises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchEnterprises() {
    ref.read(enterpriseListProvider.notifier).getEnterprises(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      status: _selectedStatus,
      coachId: _selectedCoachId,
    );
  }

  void _showReassignDialog(EnterpriseEntity enterprise) {
    // We'll need a way for the user to pick a coach from their region.
    // Re-using usersListProvider filtered for coaches.
    showDialog(
      context: context,
      builder: (context) => _ReassignCoachDialog(
        enterpriseId: enterprise.id,
        currentCoachId: enterprise.coachId,
        onAssigned: () {
          _fetchEnterprises();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseList = ref.watch(enterpriseListProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enterprises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (user?.institutionName != null)
              Text(user!.institutionName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchEnterprises,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF3D5AFE),
            child: Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchEnterprises(),
                    decoration: InputDecoration(
                      hintText: 'Search business name...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _fetchEnterprises();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        value: _selectedStatus,
                        hint: 'All Status',
                        items: ['active', 'stalled', 'graduated'],
                        onChanged: (val) {
                          setState(() => _selectedStatus = val);
                          _fetchEnterprises();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final coachesAsync = ref.watch(usersListProvider);
                          return coachesAsync.maybeWhen(
                            data: (users) {
                              final coaches = users.where((u) => u.role == 'coach').toList();
                              return _buildFilterDropdown(
                                value: _selectedCoachId,
                                hint: 'All Coaches',
                                items: coaches.map((c) => c.id).toList(),
                                itemLabels: coaches.map((c) => c.name).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCoachId = val);
                                  _fetchEnterprises();
                                },
                              );
                            },
                            orElse: () => _buildFilterDropdown(
                              value: null,
                              hint: 'Coaches...',
                              items: [],
                              onChanged: (_) {},
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: enterpriseList.when(
              data: (enterprises) => _buildList(enterprises),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.enterpriseForm),
        backgroundColor: const Color(0xFF3D5AFE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Enterprise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    List<String>? itemLabels,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          dropdownColor: const Color(0xFF3D5AFE),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          isExpanded: true,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All ${hint.split(' ').last}'),
            ),
            ...List.generate(items.length, (index) {
              return DropdownMenuItem<String>(
                value: items[index],
                child: Text(itemLabels != null ? itemLabels[index] : items[index].toUpperCase()),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildList(List<EnterpriseEntity> enterprises) {
    if (enterprises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No enterprises matches your filters', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchEnterprises(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enterprises.length,
        itemBuilder: (context, index) {
          final enterprise = enterprises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  EnterpriseCard(
                    enterprise: enterprise,
                    onTap: () => context.push('/enterprises/detail/${enterprise.id}'),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/enterprises/detail/${enterprise.id}'),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('VIEW'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3D5AFE),
                            side: const BorderSide(color: Color(0xFF3D5AFE)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showReassignDialog(enterprise),
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text('REASSIGN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5AFE),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReassignCoachDialog extends ConsumerStatefulWidget {
  final String enterpriseId;
  final String? currentCoachId;
  final VoidCallback onAssigned;

  const _ReassignCoachDialog({
    required this.enterpriseId,
    required this.currentCoachId,
    required this.onAssigned,
  });

  @override
  ConsumerState<_ReassignCoachDialog> createState() => _ReassignCoachDialogState();
}

class _ReassignCoachDialogState extends ConsumerState<_ReassignCoachDialog> {
  String? _selectedCoachId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.currentCoachId;
  }

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(usersListProvider);

    return AlertDialog(
      title: const Text('Assign Coach'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: coachesAsync.when(
        data: (users) {
          final coaches = users.where((u) => u.role == 'coach').toList();
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                return RadioListTile<String>(
                  title: Text(coach.name),
                  subtitle: Text(coach.email),
                  value: coach.id,
                  groupValue: _selectedCoachId,
                  onChanged: (val) => setState(() => _selectedCoachId = val),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Error: $err'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('CONFIRM'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final success = await ref.read(enterpriseListProvider.notifier).assignEnterprise(widget.enterpriseId, _selectedCoachId);
    if (success) {
      widget.onAssigned();
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _isSubmitting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reassign coach')));
    }
  }
}
