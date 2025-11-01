/// Route isimleri için sabitler
class RouteNames {
  RouteNames._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Main Routes
  static const String home = '/home';
  static const String aircraftDetail = '/aircraft/:id';
  static const String booking = '/booking/:id';
  static const String profile = '/profile';
  static const String bookings = '/bookings';

  // Admin Routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
}

