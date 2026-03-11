// TODO: Enterprise detail screen — full profile of a single enterprise
// Sections: Business Info, Owner Info, Assessment Summary, Recent Sessions
// Actions: Start Assessment, Add Session, View Progress

import 'package:flutter/material.dart';

class EnterpriseDetailScreen extends StatelessWidget {
  const EnterpriseDetailScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Enterprise Detail — TODO')),
    );
  }
}
