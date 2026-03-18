// TODO: Diagnosis result screen — shows assessment outcome
// - Overall score gauge
// - Category breakdown bar chart (using fl_chart)
// - Priority areas list (auto-identified challenges)
// - CTA: Start Coaching Session based on these findings

import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Diagnosis Result — TODO')),
    );
  }
}
