// TODO: Stat/metric card for dashboards
// Props: title, value, subtitle, icon, color

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement card with icon, title, large value, optional subtitle
    throw UnimplementedError();
  }
}
