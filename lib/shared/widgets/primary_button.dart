// TODO: Reusable primary action button used across all features
// Props: label, onPressed, isLoading, isFullWidth

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement button with loading spinner state
    throw UnimplementedError();
  }
}
