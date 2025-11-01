import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/firebase/firebase_service.dart';

/// Splash ekranı
/// Firebase başlatma ve auth kontrolü yapar
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Uygulamayı başlat
  Future<void> _initializeApp() async {
    try {
      // Firebase zaten main.dart'ta initialize edildi
      // Auth durumunu kontrol et
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final user = FirebaseService.currentUser;
      if (user != null) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.login);
      }
    } catch (e) {
      // Hata durumunda login'e yönlendir
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Icon(
                Icons.flight,
                size: 120,
                color: AppColors.gold,
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'AIRLUX',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Luxury Aviation Experience',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

