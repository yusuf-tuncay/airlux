/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  AppConstants._();

  // App Bilgileri
  static const String appName = 'Airlux';
  static const String appTagline = 'Luxury Aviation Experience';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double ultraDesktopBreakpoint = 1800;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Pagination
  static const int defaultPageSize = 20;
  static const int aircraftPageSize = 12;

  // Cache Durations
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration dataCacheDuration = Duration(hours: 1);
}

