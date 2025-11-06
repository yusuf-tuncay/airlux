import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Hero Section Widget - Teknevia tarzı tam ekran hero section
class HeroSection extends StatefulWidget {
  final Widget searchBar;

  const HeroSection({
    super.key,
    required this.searchBar,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A1A2E), // Koyu lacivert
            const Color(0xFF1A2B3E), // Orta lacivert
            const Color(0xFF0F1E2E), // Daha koyu lacivert
            const Color(0xFF0A1A2E), // Tekrar koyu
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Gökyüzü/Özel Jet Arka Plan Görseli
          Positioned.fill(
            child: CustomPaint(
              painter: _SkyPainter(),
              size: Size(screenWidth, screenHeight),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // İçerik
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 48,
                  vertical: isMobile ? 40 : 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ana Başlık
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Tek tıkla özel jet kirala!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 32 : 64,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: isMobile ? -0.5 : -1.5,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 32 : 48),

                    // Arama Bar
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: widget.searchBar,
                      ),
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Açıklama Metni
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'AirLux: Türkiye\'nin ilk anında rezervasyon yapabileceğiniz özel hava kiralama platformu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.95),
                            letterSpacing: 0.3,
                            height: 1.6,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/// Gökyüzü efekti için optimize edilmiş custom painter
class _SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Bulut benzeri efektler - daha yumuşak
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.softLight;

    // Büyük bulut
    final cloud1 = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.25),
          radius: size.width * 0.18,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.3, size.height * 0.3),
          radius: size.width * 0.12,
        ),
      );
    cloudPaint.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawPath(cloud1, cloudPaint);

    // İkinci bulut
    final cloud2 = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.35),
          radius: size.width * 0.15,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.4),
          radius: size.width * 0.1,
        ),
      );
    cloudPaint.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawPath(cloud2, cloudPaint);

    // Yıldız efekti - daha fazla yıldız
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final starCount = (size.width * size.height / 15000).round().clamp(30, 60);
    for (int i = 0; i < starCount; i++) {
      final x = (i * 137.5) % size.width;
      final y = (i * 197.3) % size.height;
      final starSize = (i % 3 == 0) ? 2.0 : 1.5;
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    // Parlayan yıldızlar
    final brightStarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (i * 347.7) % size.width;
      final y = (i * 523.1) % size.height;
      canvas.drawCircle(Offset(x, y), 2.5, brightStarPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

