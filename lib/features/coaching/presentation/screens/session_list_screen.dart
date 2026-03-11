// TODO: Session list screen — all sessions for a specific enterprise
// Shows: date, status badge, problems summary
// Can filter by: scheduled / completed / cancelled

import 'package:flutter/material.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Session List — TODO')),
    );
  }
}
