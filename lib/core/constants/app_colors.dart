import 'package:flutter/material.dart';

/// Piano Black + Gold Luxury Theme
/// Parlak siyah yüzeyler, altın yansımalar, VIP atmosfer
class AppColors {
  AppColors._();

  // Piano Black Theme - Primary Colors
  static const Color pianoBlack = Color(0xFF0A0A0A); // Ana arka plan
  static const Color jetBlack = Color(0xFF141414); // Gradient / gölge
  static const Color graphiteGrey = Color(0xFF2C2C2C); // Kart zeminleri

  // Silver - Premium Accent
  static const Color silver = Color(0xFFC0C0C0); // Buton, vurgu, logo
  static const Color silverLight = Color(0xFFE8E8E8);
  static const Color silverMedium = Color(0xFFC0C0C0);
  static const Color silverDark = Color(0xFFA8A8A8);
  static const Color silverAccent = Color(0xFFC0C0C0);
  static const Color silverShimmer = Color(0xFFE8E8E8);
  static const Color platinum = Color(0xFFE5E4E2);
  
  // Backward compatibility
  static const Color champagneGold = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFC0C0C0);
  static const Color goldLight = Color(0xFFE8E8E8);
  static const Color goldMedium = Color(0xFFC0C0C0);
  static const Color goldDark = Color(0xFFA8A8A8);
  static const Color goldAccent = Color(0xFFC0C0C0);
  static const Color goldShimmer = Color(0xFFE8E8E8);

  // Text Colors - Soft White
  static const Color textPrimary = Color(0xFFEDEDED); // Soft White
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF8A8A8A);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0A); // Piano Black
  static const Color primaryDark = Color(0xFF0A0A0A);
  static const Color primaryDarkLight = Color(0xFF141414); // Jet Black
  static const Color secondaryDark = Color(0xFF141414);
  static const Color backgroundCard = Color(0xFF2C2C2C); // Graphite Grey
  static const Color backgroundCardHover = Color(0xFF3A3A3A);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Border Colors
  static const Color borderLight = Color(0xFF3A3A3A);
  static const Color borderMedium = Color(0xFF4A4A4A);
  static const Color borderGold = Color(0xFFC0C0C0); // Silver
  static const Color borderSilver = Color(0xFFC0C0C0);

  // Gradient Colors - Piano Black + Silver
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [silverLight, silverMedium, silver],
  );

  static const LinearGradient premiumGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8E8E8), // Light silver
      Color(0xFFC0C0C0), // Silver
      Color(0xFFA8A8A8), // Dark silver
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [silverLight, silverMedium, silverDark],
  );
  
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [silverLight, silverMedium, silverDark],
  );

  // Piano Black Gradient - 135deg
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pianoBlack, jetBlack], // 135deg gradient
  );
}

