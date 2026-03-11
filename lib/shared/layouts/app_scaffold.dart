// TODO: Common app scaffold with navigation drawer (for supervisor/admin)
// and bottom navigation bar (for coach role)
// Reads current user role from authProvider to decide nav type

import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement role-aware navigation wrapper
    throw UnimplementedError();
  }
}
