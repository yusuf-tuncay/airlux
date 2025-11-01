import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive breakpoint kontrolü için yardımcı sınıf
class Responsive {
  /// Ekran genişliğine göre breakpoint kontrolü
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.desktopBreakpoint &&
        width < AppConstants.ultraDesktopBreakpoint;
  }

  static bool isUltraDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        AppConstants.ultraDesktopBreakpoint;
  }

  /// Breakpoint'e göre değer döndürür
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultraDesktop,
  }) {
    if (isUltraDesktop(context) && ultraDesktop != null) {
      return ultraDesktop;
    }
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Ekran genişliğini döndürür
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Ekran yüksekliğini döndürür
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

