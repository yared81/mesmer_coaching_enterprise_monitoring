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
  bool _showFilters = false;

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
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                    key: ValueKey(_showFilters),
                  ),
                ),
                onPressed: () => setState(() => _showFilters = !_showFilters),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_showFilters ? 108 : 56),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _onSearch(),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search enterprises…',
                          hintStyle: const TextStyle(color: Colors.white60),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
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
                  // Filter chips
                  if (_showFilters)
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        children: [
                          _buildFilterChip(null, 'All'),
                          ...Sector.values.map((s) => _buildFilterChip(s, s.name)),
                        ],
                      ),
                    ),
                ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.enterpriseForm),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Enterprise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF3D5AFE) : Colors.white.withOpacity(0.9),
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
