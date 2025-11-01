import 'package:go_router/go_router.dart';
import '../../core/constants/route_names.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/aircraft/presentation/pages/home_page.dart';
import '../../features/aircraft/presentation/pages/aircraft_detail_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../core/firebase/firebase_service.dart';

/// Uygulama routing yapılandırması
final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  redirect: (context, state) {
    // Eğer kullanıcı giriş yapmışsa ve login/register sayfasındaysa home'a yönlendir
    final user = FirebaseService.currentUser;
    final isOnLogin = state.uri.path == RouteNames.login;
    final isOnRegister = state.uri.path == RouteNames.register;
    
    if (user != null && (isOnLogin || isOnRegister)) {
      return RouteNames.home;
    }
    
    // Eğer kullanıcı giriş yapmamışsa ve home sayfasındaysa login'e yönlendir
    if (user == null && state.uri.path == RouteNames.home) {
      return RouteNames.login;
    }
    
    return null; // Yönlendirme yok
  },
  routes: [
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

