import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

class EnterpriseFilterSheet extends ConsumerStatefulWidget {
  const EnterpriseFilterSheet({super.key});

  @override
  ConsumerState<EnterpriseFilterSheet> createState() => _EnterpriseFilterSheetState();
}

class _EnterpriseFilterSheetState extends ConsumerState<EnterpriseFilterSheet> {
  String? _selectedSector;
  String? _selectedStatus;
  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Enterprises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          const Text('Sector', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSectorChips(),
          
          const SizedBox(height: 24),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildStatusChips(),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _resetFilters,
            child: const Center(child: Text('Reset All', style: TextStyle(color: Colors.red))),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectorChips() {
    final sectors = ['Agriculture', 'Manufacturing', 'Service', 'Retail', 'Other'];
    return Wrap(
      spacing: 8,
      children: sectors.map((s) {
        final isSelected = _selectedSector == s;
        return ChoiceChip(
          label: Text(s),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedSector = val ? s : null),
          selectedColor: AppColors.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildStatusChips() {
    final statuses = ['active', 'stalled', 'graduated'];
    return Wrap(
      spacing: 8,
      children: statuses.map((s) {
        final isSelected = _selectedStatus == s;
        return ChoiceChip(
          label: Text(s.toUpperCase()),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedStatus = val ? s : null),
          selectedColor: AppColors.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  void _applyFilters() {
    ref.read(enterpriseListProvider.notifier).getEnterprises(
      sector: _selectedSector,
      status: _selectedStatus,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedSector = null;
      _selectedStatus = null;
    });
    ref.read(enterpriseListProvider.notifier).getEnterprises();
    Navigator.pop(context);
  }
}
