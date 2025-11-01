import 'package:flutter/material.dart';

/// Lüks aviasyon teması için renk paleti
/// Koyu tonlar + altın detaylar
class AppColors {
  AppColors._();

  // Primary Colors - Dark Theme
  static const Color primaryDark = Color(0xFF0A0E27); // Koyu lacivert
  static const Color primaryDarkLight = Color(0xFF1A1F3A);
  static const Color secondaryDark = Color(0xFF141B33);

  // Gold Accent Colors - Premium tones
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFE87C);
  static const Color goldMedium = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8941F);
  static const Color goldAccent = Color(0xFFFFE87C);
  static const Color goldShimmer = Color(0xFFFFF8DC);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C4);
  static const Color textTertiary = Color(0xFF8A95A6);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color backgroundCard = Color(0xFF1A1F3A);
  static const Color backgroundCardHover = Color(0xFF232844);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Border Colors
  static const Color borderLight = Color(0xFF2A3441);
  static const Color borderMedium = Color(0xFF3A4451);
  static const Color borderGold = Color(0xFFD4AF37);

  // Gradient Colors - Premium Gold Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldMedium, gold],
  );

  static const LinearGradient premiumGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8DC), // Cream white
      Color(0xFFFFE87C), // Light gold
      Color(0xFFFFD700), // Gold
      Color(0xFFD4AF37), // Classic gold
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldMedium, goldDark],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, secondaryDark],
  );
}

