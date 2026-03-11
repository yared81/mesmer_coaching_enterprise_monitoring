// TODO: Indicator chart screen — detailed comparison chart for a specific indicator
// - Bar chart: baseline vs latest per category (fl_chart BarChart)
// - Table: all assessment sessions with dates and scores

import 'package:flutter/material.dart';

class IndicatorChartScreen extends StatelessWidget {
  const IndicatorChartScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Indicator Chart — TODO')),
    );
  }
}
