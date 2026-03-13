import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF3D5AFE); // Premium Blue
  static const Color secondary = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFFCC33); // Golden/Amber accent
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F7F7);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textPlaceholder = Color(0xFFAAAAAA);
  
  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Borders & Dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
}
