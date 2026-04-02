import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final config = _roleConfig(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  _RoleConfig _roleConfig(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return _RoleConfig('Super Admin', const Color(0xFF7C3AED));
      case 'program_manager':
      case 'programmanager':
        return _RoleConfig('Program Manager', const Color(0xFF1D4ED8));
      case 'regional_coordinator':
      case 'regionalcoordinator':
        return _RoleConfig('Regional Coord.', const Color(0xFF0369A1));
      case 'me_officer':
      case 'meofficer':
        return _RoleConfig('M&E Officer', const Color(0xFF0F766E));
      case 'data_verifier':
      case 'dataverifier':
        return _RoleConfig('Data Verifier', const Color(0xFF6D28D9));
      case 'trainer':
        return _RoleConfig('Trainer', const Color(0xFFB45309));
      case 'coach':
        return _RoleConfig('Coach', const Color(0xFF047857));
      case 'enumerator':
        return _RoleConfig('Enumerator', const Color(0xFF0284C7));
      case 'comms_officer':
      case 'commsofficer':
        return _RoleConfig('Comms Officer', const Color(0xFFBE185D));
      case 'enterprise':
      case 'enterprise_user':
        return _RoleConfig('Enterprise', const Color(0xFFD97706));
      case 'stakeholder':
        return _RoleConfig('Stakeholder', const Color(0xFF64748B));
      default:
        return _RoleConfig(role, const Color(0xFF64748B));
    }
  }
}

class _RoleConfig {
  final String label;
  final Color color;
  const _RoleConfig(this.label, this.color);
}
