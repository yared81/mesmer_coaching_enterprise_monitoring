import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'enterprise_provider.dart';
import 'enterprise_card.dart';
import 'enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'enterprise_filter_sheet.dart';

class EnterpriseListScreen extends ConsumerStatefulWidget {
  const EnterpriseListScreen({super.key});

  @override
  ConsumerState<EnterpriseListScreen> createState() => _EnterpriseListScreenState();
}

class _EnterpriseListScreenState extends ConsumerState<EnterpriseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(enterpriseListProvider.notifier).getEnterprises(
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnterpriseFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseList = ref.watch(enterpriseListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
            title: const Text('Enterprises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            actions: [
               IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _onSearch,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _onSearch(),
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
                                      _onSearch();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.filter_list_rounded, color: Color(0xFF3D5AFE)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: enterpriseList.when(
          data: (enterprises) => _buildList(enterprises),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildError(err.toString()),
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        final role = ref.watch(authProvider).user?.role;
        // Only supervisors and admins can register new enterprises
        if (role == UserRole.coach) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.enterpriseForm),
          backgroundColor: const Color(0xFF3D5AFE),
          elevation: 4,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Enterprise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }),
    );
  }

  Widget _buildFilterChip(Sector? sector, String label) {
    final isSelected = _selectedSector == sector;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label[0].toUpperCase() + label.substring(1)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSector = selected ? sector : null;
          });
          _onSearch();
        },
        backgroundColor: Colors.white.withOpacity(0.85),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF3D5AFE) : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
            Icon(Icons.business_center_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No enterprises found', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _onSearch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: enterprises.length,
        itemBuilder: (context, index) {
          final enterprise = enterprises[index];
          return EnterpriseCard(
            enterprise: enterprise,
            onTap: () {
              context.push('/enterprises/detail/${enterprise.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          TextButton(
            onPressed: _onSearch,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
