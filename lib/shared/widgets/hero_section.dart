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

    return Container(
      height: screenHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A), // Piano Black
            Color(0xFF141414), // Jet Black
          ],
        ),
      ),
      child: Stack(
        children: [
          // Arka plan fotoğrafı
          Positioned.fill(
            child: Image.asset(
              'assets/images/privatejet1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A0A0A), // Piano Black
                        Color(0xFF141414), // Jet Black
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Koyu overlay - metinlerin okunabilirliği için (Piano Black gradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A0A).withValues(alpha: 0.4), // Piano Black
                    const Color(0xFF0A0A0A).withValues(alpha: 0.6), // Piano Black
                    const Color(0xFF141414).withValues(alpha: 0.7), // Jet Black
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // İçerik
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isMobile ? 20 : 48,
                  right: isMobile ? 20 : 48,
                  top: isMobile ? 60 : 100,
                  bottom: isMobile ? 40 : 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            color: const Color(0xFFEDEDED), // Soft White
                            letterSpacing: isMobile ? -0.5 : -1.5,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFC0C0C0).withValues(alpha: 0.4), // Silver shadow
                                offset: const Offset(0, 2),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
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
                            color: const Color(0xFFEDEDED).withValues(alpha: 0.9), // Soft White
                            letterSpacing: 0.3,
                            height: 1.6,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
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
