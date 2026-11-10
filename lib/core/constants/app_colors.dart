import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette - Modern Teal & Emerald
  static const Color primary = Color(0xFF0F766E); // Modern Teal 700
  static const Color primaryDark = Color(0xFF115E59); // Teal 800
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color accent = Color(0xFF2DD4BF); // Teal 400

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Typography / Slate Palette
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // System & Feedback
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color star = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF115E59), Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
