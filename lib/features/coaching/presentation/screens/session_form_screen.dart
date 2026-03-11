// TODO: Session form screen — create/edit a coaching session
// Fields: date picker, problems identified, recommendations, session notes
// Task section: add improvement tasks with due dates
// Bottom button: Save Session

import 'package:flutter/material.dart';

class SessionFormScreen extends StatelessWidget {
  const SessionFormScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Session Form — TODO')),
    );
  }
}
