import 'package:go_router/go_router.dart';
import '../../core/constants/route_names.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/aircraft/presentation/pages/home_page.dart';
import '../../features/aircraft/presentation/pages/aircraft_detail_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';

/// Uygulama routing yapılandırması
final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    // Splash
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // Auth Routes
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),

    // Main Routes
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/aircraft/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AircraftDetailPage(aircraftId: id);
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BookingPage(aircraftId: id);
      },
    ),
  ],
);

