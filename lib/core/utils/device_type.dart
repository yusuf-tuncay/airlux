import 'package:flutter/material.dart';
import 'responsive.dart';

/// Cihaz tipi enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  ultraDesktop,
}

/// Cihaz tipi belirleme yardımcı sınıfı
class DeviceTypeHelper {
  /// BuildContext'ten cihaz tipini belirler
  static DeviceType getDeviceType(BuildContext context) {
    if (Responsive.isUltraDesktop(context)) {
      return DeviceType.ultraDesktop;
    } else if (Responsive.isDesktop(context)) {
      return DeviceType.desktop;
    } else if (Responsive.isTablet(context)) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Cihaz tipine göre grid column sayısı
  static int getGridColumnCount(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.ultraDesktop:
        return 4;
    }
  }
}

