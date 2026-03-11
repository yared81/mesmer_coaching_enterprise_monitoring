// TODO: Error state widget shown when API calls fail
// Props: message, onRetry

import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // TODO: Show error icon, message, and optional retry button
    throw UnimplementedError();
  }
}
