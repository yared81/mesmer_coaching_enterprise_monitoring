import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

class CoachEnterpriseListScreen extends ConsumerStatefulWidget {
  const CoachEnterpriseListScreen({super.key});

  @override
  ConsumerState<CoachEnterpriseListScreen> createState() => _CoachEnterpriseListScreenState();
}

class _CoachEnterpriseListScreenState extends ConsumerState<CoachEnterpriseListScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final filteredEnterprises = ref.watch(filteredEnterprisesProvider);
    final selectedSector = ref.watch(coachEnterpriseSectorFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Enterprises', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilters ? 52 : 0),
          child: _showFilters 
            ? Container(
                height: 52,
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(null, 'All', selectedSector),
                    ...Sector.values.map((s) => _buildFilterChip(s, s.name, selectedSector)),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        ),
      ),
      body: filteredEnterprises.when(
        data: (enterprises) {
          if (enterprises.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enterprises.length,
            itemBuilder: (context, index) {
              final enterprise = enterprises[index];
              return _EnterpriseCard(enterprise: enterprise);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFilterChip(Sector? sector, String label, Sector? selectedSector) {
    final isSelected = selectedSector == sector;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label[0].toUpperCase() + label.substring(1)),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(coachEnterpriseSectorFilterProvider.notifier).state = selected ? sector : null;
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).cardColor,
        side: BorderSide(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Theme.of(context).hintColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text(
            'No enterprises found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _EnterpriseCard extends StatelessWidget {
  final EnterpriseEntity enterprise;
  const _EnterpriseCard({required this.enterprise});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => context.push('/enterprises/detail/${enterprise.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enterprise.businessName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enterprise.sector.name,
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'v85%', // Placeholder for now
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
