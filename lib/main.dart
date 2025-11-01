import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'shared/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AirluxApp(),
    ),
  );
}

/// Ana uygulama widget'ı
class AirluxApp extends StatelessWidget {
  const AirluxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Airlux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
