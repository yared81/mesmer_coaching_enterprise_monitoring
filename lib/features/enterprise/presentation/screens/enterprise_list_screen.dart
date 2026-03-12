import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/enterprise_provider.dart';
import '../widgets/enterprise_card.dart';
import '../../domain/entities/enterprise_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';

class EnterpriseListScreen extends ConsumerStatefulWidget {
  const EnterpriseListScreen({super.key});

  @override
  ConsumerState<EnterpriseListScreen> createState() => _EnterpriseListScreenState();
}

class _EnterpriseListScreenState extends ConsumerState<EnterpriseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Sector? _selectedSector;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(enterpriseListProvider.notifier).getEnterprises(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      sector: _selectedSector,
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseList = ref.watch(enterpriseListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Enterprises',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sorting
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: enterpriseList.when(
              data: (enterprises) => _buildList(enterprises),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildError(err.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.enterpriseForm),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Enterprise'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Search enterprises...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                ...Sector.values.map((s) => _buildFilterChip(s, s.name)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(Sector? sector, String label) {
    final isSelected = _selectedSector == sector;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          setState(() {
            _selectedSector = selected ? sector : null;
          });
          _onSearch();
        },
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
