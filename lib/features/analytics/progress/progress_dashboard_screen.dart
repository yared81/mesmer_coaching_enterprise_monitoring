// TODO: Progress dashboard screen — shows enterprise improvement over time
// - Overall score gauge (baseline vs current)
// - Line chart: score trend since first assessment (fl_chart LineChart)
// - Indicator breakdown: bookkeeping, sales, loan repayment, operations

import 'package:flutter/material.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Progress Dashboard — TODO')),
    );
  }
}
