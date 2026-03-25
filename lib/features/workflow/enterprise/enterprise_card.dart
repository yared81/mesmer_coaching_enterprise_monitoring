import 'package:flutter/material.dart';
import 'enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';

class EnterpriseCard extends StatelessWidget {
  const EnterpriseCard({
    super.key,
    required this.enterprise,
    this.onTap,
  });

  final EnterpriseEntity enterprise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        enterprise.businessName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SectorBadge(sector: enterprise.sector),
                        const SizedBox(height: 4),
                        _StatusBadge(status: enterprise.status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Owner: ${enterprise.ownerName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _IconInfo(
                      icon: Icons.people_outline,
                      label: '${enterprise.employeeCount} Employees',
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _IconInfo(
                      icon: Icons.location_on_outlined,
                      label: enterprise.location,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectorBadge extends StatelessWidget {
  const _SectorBadge({required this.sector});
  final Sector sector;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (sector) {
      case Sector.agriculture: color = Colors.green; break;
      case Sector.manufacturing: color = Colors.blue; break;
      case Sector.trade: color = Colors.orange; break;
      case Sector.services: color = Colors.purple; break;
      case Sector.construction: color = Colors.brown; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        sector.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final EnterpriseStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case EnterpriseStatus.graduated:
        color = const Color(0xFF10B981); // Emerald
        text = 'GRADUATED';
        break;
      case EnterpriseStatus.pilot:
        color = const Color(0xFF3B82F6); // Blue
        text = 'PILOT';
        break;
      case EnterpriseStatus.stalled:
        color = const Color(0xFFF59E0B); // Amber
        text = 'STALLED';
        break;
      case EnterpriseStatus.dropped:
        color = const Color(0xFFEF4444); // Red
        text = 'DROPPED';
        break;
      case EnterpriseStatus.active:
      default:
        color = const Color(0xFF6366F1); // Indigo
        text = 'ACTIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == EnterpriseStatus.graduated)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.school, size: 10, color: Colors.white),
            ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconInfo extends StatelessWidget {
  const _IconInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
