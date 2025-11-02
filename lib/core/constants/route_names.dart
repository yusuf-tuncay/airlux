/// Route isimleri için sabitler
class RouteNames {
  RouteNames._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneNumber = '/phone-number';

  // Main Routes
  static const String home = '/home';
  static const String search = '/search';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String aircraftDetail = '/aircraft/:id';
  static const String booking = '/booking/:id';

  // Admin Routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
}

