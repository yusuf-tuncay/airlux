import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Profesyonel animasyonlu arka plan widget'ı
/// Lüks havacılık teması için özel tasarlandı
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particlesController;
  late AnimationController _starsController;

  @override
  void initState() {
    super.initState();

    // Gradient animasyon controller
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Parçacık animasyon controller
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Yıldız animasyon controller
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particlesController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animasyonlu gradient arka plan
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    Color.lerp(
                      AppColors.primaryDark,
                      AppColors.secondaryDark,
                      _gradientController.value,
                    )!,
                    AppColors.secondaryDark,
                  ],
                  stops: [
                    0.0,
                    _gradientController.value * 0.5 + 0.25,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),

        // Parıldayan yıldızlar
        AnimatedBuilder(
          animation: _starsController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(_starsController.value),
              size: Size.infinite,
            );
          },
        ),

        // Uçan parçacıklar
        AnimatedBuilder(
          animation: _particlesController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlesPainter(_particlesController.value),
              size: Size.infinite,
            );
          },
        ),

        // İçerik
        widget.child,
      ],
    );
  }
}

/// Parıldayan yıldızlar için custom painter
class StarsPainter extends CustomPainter {
  final double animationValue;

  StarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.silverMedium
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Sabit seed for consistent stars

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      final radius = 1.0 + (opacity * 1.5);

      paint.color = AppColors.silverMedium.withValues(
        alpha: opacity * 0.6,
      );

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Büyük yıldızlar için çapraz çizgiler
      if (opacity > 0.5) {
        paint.strokeWidth = 0.5;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(x - 3, y),
          Offset(x + 3, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - 3),
          Offset(x, y + 3),
          paint,
        );
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Uçan parçacıklar için custom painter
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.silver
      ..style = PaintingStyle.fill;

    final random = math.Random(123); // Sabit seed

    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 20 + random.nextDouble() * 40;
      final y = (size.height + (animationValue * speed * 100)) %
              (size.height + 100) -
          50;
      final x = baseX + math.sin(animationValue * 2 * math.pi + i) * 20;

      final opacity = (math.sin(animationValue * 3 * math.pi + i) + 1) / 2;
      final radius = 2.0 + (opacity * 3);

      paint.color = AppColors.silverLight.withValues(
        alpha: opacity * 0.3,
      );

      // Gradient efekti için blur
      final blurPaint = Paint()
        ..color = AppColors.silverLight.withValues(alpha: opacity * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x, y), radius * 2, blurPaint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

