// TODO: Role badge chip shown on user profiles and cards
// Props: role (admin | institution_admin | supervisor | coach)

import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    // TODO: Map role to color using AppColors.roleAdmin/roleSupervisor/roleCoach
    // TODO: Return styled Chip widget
    throw UnimplementedError();
  }
}
