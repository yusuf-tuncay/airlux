import 'package:go_router/go_router.dart';
import '../../core/constants/route_names.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/phone_number_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/settings_page.dart';
import '../../features/aircraft/presentation/pages/home_page.dart';
import '../../features/aircraft/presentation/pages/aircraft_detail_page.dart';
import '../../features/aircraft/presentation/pages/search_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/bookings_page.dart';
import '../../core/firebase/firebase_service.dart';

/// Uygulama routing yapılandırması
final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  redirect: (context, state) {
    final user = FirebaseService.currentUser;
    final currentPath = state.uri.path;
    
    // Public sayfalar - herkese açık (login gerektirmez)
    final publicPaths = [
      RouteNames.home,
      RouteNames.search,
      RouteNames.login,
      RouteNames.register,
    ];
    
    // Protected sayfalar - sadece giriş yapmış kullanıcılar erişebilir
    final protectedPaths = [
      RouteNames.bookings,
      RouteNames.profile,
      RouteNames.settings,
    ];
    
    // Aircraft detail sayfası public (yol path kontrolü)
    final isAircraftDetail = currentPath.startsWith('/aircraft/');
    
    // Booking sayfası protected (yol path kontrolü)
    final isBookingPage = currentPath.startsWith('/booking/');
    
    // Eğer kullanıcı giriş yapmamışsa
    if (user == null) {
      // Public sayfalara erişebilir
      if (publicPaths.contains(currentPath) || isAircraftDetail) {
        return null;
      }
      // Protected sayfalara veya booking sayfasına erişmeye çalışıyorsa login'e yönlendir
      if (protectedPaths.contains(currentPath) || isBookingPage) {
        return RouteNames.login;
      }
    }
    
    // NOT: Telefon numarası kontrolü GEÇİCİ OLARAK KALDIRILDI
    // Kullanıcı telefon numarası girmeden de devam edebilir
    // Telefon numarası sayfasına erişim serbest ama zorunlu değil
    
    // NOT: Kullanıcı giriş yapmış olsa bile login sayfasına erişebilmeli
    // (Beni Hatırla özelliği için veriler yüklenebilsin diye)
    
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
    GoRoute(
      path: RouteNames.phoneNumber,
      builder: (context, state) => const PhoneNumberPage(),
    ),

    // Main Routes
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteNames.search,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: RouteNames.bookings,
      builder: (context, state) => const BookingsPage(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
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

