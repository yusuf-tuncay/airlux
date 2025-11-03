import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_names.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Aviation Blue color palette
const Color _iceGray = Color(0xFFB4BEC9); // Buz grisi - Vurgu
const Color _lightGold = Color(0xFFD6C37D); // Açık altın - Accent

/// Responsive layout widget'ı
/// Cihaz tipine göre farklı layout'lar gösterir
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultraDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isUltraDesktop(context) && ultraDesktop != null) {
      return ultraDesktop!;
    }
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Scaffold wrapper with responsive layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int? bottomNavIndex;
  final Function(int)? onBottomNavTap;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavIndex,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: title != null
            ? AppBar(title: Text(title!), actions: actions)
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavIndex != null && onBottomNavTap != null
            ? BottomNavigationBar(
                currentIndex: bottomNavIndex! < 4
                    ? bottomNavIndex!
                    : 0, // 0-3 arası olmalı (4 öğe var)
                onTap: onBottomNavTap,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flight),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Bookings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
      ),
      tablet: Scaffold(
        appBar: title != null || (actions != null && actions!.isNotEmpty)
            ? AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
              )
            : null,
        body: Row(
          children: [
            // Premium Side Navigation
            Consumer(
              builder: (context, ref, child) {
                return _PremiumNavigationRail(
                  selectedIndex: bottomNavIndex ?? 0,
                  onDestinationSelected: onBottomNavTap ?? (_) {},
                  extended: false,
                );
              },
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: AppColors.borderMedium,
            ),
            // Body
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
      desktop: Scaffold(
        appBar: title != null || (actions != null && actions!.isNotEmpty)
            ? AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
              )
            : null,
        body: Row(
          children: [
            // Premium Side Navigation
            Consumer(
              builder: (context, ref, child) {
                return _PremiumNavigationRail(
                  selectedIndex: bottomNavIndex ?? 0,
                  onDestinationSelected: onBottomNavTap ?? (_) {},
                  extended: true,
                );
              },
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: AppColors.borderMedium,
            ),
            // Body
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

/// Premium Navigation Rail - Modern Minimal Design
class _PremiumNavigationRail extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool extended;

  const _PremiumNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: extended ? 260 : 72,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Minimal Header
          _buildMinimalHeader(extended),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: extended ? 24 : 16, bottom: 16),
              children: [
                _buildNavItem(
                  icon: Icons.flight_rounded,
                  label: 'Ana Sayfa',
                  index: 0,
                  extended: extended,
                ),
                SizedBox(height: extended ? 12 : 8),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: 'Ara',
                  index: 1,
                  extended: extended,
                ),
                SizedBox(height: extended ? 12 : 8),
                _buildNavItem(
                  icon: Icons.book_rounded,
                  label: 'Rezervasyonlar',
                  index: 2,
                  extended: extended,
                ),
                SizedBox(height: extended ? 12 : 8),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  index: 3,
                  extended: extended,
                ),
              ],
            ),
          ),

          // Fixed Bottom Section - Ayarlar ve Çıkış Yap
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderMedium,
                indent: 16,
                endIndent: 16,
              ),
              SizedBox(height: extended ? 12 : 8),
              _buildNavItem(
                icon: Icons.settings_rounded,
                label: 'Ayarlar',
                index: 4,
                extended: extended,
              ),
              SizedBox(height: extended ? 12 : 8),
              _buildAuthButton(context, extended, ref),
              SizedBox(height: extended ? 16 : 12),
              // Footer
              _buildFooter(extended),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader(bool extended) {
    return Container(
      padding: EdgeInsets.all(extended ? 24 : 16),
      child: extended
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _lightGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _lightGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: _lightGold,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Airlux',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium Aviation',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lightGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: _lightGold,
                  size: 22,
                ),
              ),
            ),
    );
  }

  Widget _buildFooter(bool extended) {
    return Container(
      padding: EdgeInsets.all(extended ? 16 : 12),
      child: extended
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Airlux',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 Tüm hakları saklıdır',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool extended,
  }) {
    final isSelected = selectedIndex == index;

    return _ModernNavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      extended: extended,
      onTap: () => onDestinationSelected(index),
    );
  }

  Widget _buildAuthButton(BuildContext context, bool extended, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;

    if (isLoggedIn) {
      // Kullanıcı giriş yapmışsa - Çıkış Yap butonu
      return _LogoutItem(
        extended: extended,
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'İptal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            final authNotifier = ref.read(authStateProvider.notifier);
            await authNotifier.signOut();
            if (context.mounted) {
              context.go(RouteNames.home);
            }
          }
        },
      );
    } else {
      // Kullanıcı giriş yapmamışsa - Giriş Yap butonu
      return _LoginItem(
        extended: extended,
        onTap: () {
          if (context.mounted) {
            context.go('/login');
          }
        },
      );
    }
  }
}

/// Modern Minimal Navigation Item
class _ModernNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool extended;
  final VoidCallback onTap;

  const _ModernNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.extended,
    required this.onTap,
  });

  @override
  State<_ModernNavItem> createState() => _ModernNavItemState();
}

class _ModernNavItemState extends State<_ModernNavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 16 : 8,
                  vertical: 2,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 18 : 12,
                  vertical: widget.extended ? 16 : 14,
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? _lightGold.withValues(alpha: 0.12)
                      : _isHovered
                      ? _lightGold.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: widget.extended
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: widget.extended
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    // Active Indicator Bar
                    if (widget.isSelected)
                      Container(
                        width: 3,
                        height: widget.extended ? 24 : 20,
                        margin: EdgeInsets.only(
                          right: widget.extended ? 16 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_lightGold, _iceGray],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: _lightGold.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    // Icon
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? _lightGold
                          : _isHovered
                          ? _lightGold.withValues(alpha: 0.8)
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      size: widget.extended ? 22 : 24,
                    ),
                    // Label
                    if (widget.extended) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.isSelected
                                ? _lightGold
                                : _isHovered
                                ? _lightGold.withValues(alpha: 0.9)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                            fontSize: 14,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Login Item with Aviation Blue color theme
class _LoginItem extends StatefulWidget {
  final bool extended;
  final VoidCallback onTap;

  const _LoginItem({required this.extended, required this.onTap});

  @override
  State<_LoginItem> createState() => _LoginItemState();
}

class _LoginItemState extends State<_LoginItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 16 : 8,
                  vertical: 2,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 18 : 12,
                  vertical: widget.extended ? 16 : 14,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? _lightGold.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: _isHovered
                      ? Border.all(
                          color: _lightGold.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: widget.extended
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: widget.extended
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    // Icon
                    Icon(
                      Icons.login_rounded,
                      color: _isHovered
                          ? _lightGold
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      size: widget.extended ? 22 : 24,
                    ),
                    // Label
                    if (widget.extended) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: _isHovered
                                ? _lightGold
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                            fontSize: 14,
                            fontWeight: _isHovered
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Logout Item with error color theme
class _LogoutItem extends StatefulWidget {
  final bool extended;
  final VoidCallback onTap;

  const _LogoutItem({required this.extended, required this.onTap});

  @override
  State<_LogoutItem> createState() => _LogoutItemState();
}

class _LogoutItemState extends State<_LogoutItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 16 : 8,
                  vertical: 2,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 18 : 12,
                  vertical: widget.extended ? 16 : 14,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.error.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: _isHovered
                      ? Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: widget.extended
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: widget.extended
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    // Icon
                    Icon(
                      Icons.logout_rounded,
                      color: _isHovered
                          ? AppColors.error
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      size: widget.extended ? 22 : 24,
                    ),
                    // Label
                    if (widget.extended) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Çıkış Yap',
                          style: TextStyle(
                            color: _isHovered
                                ? AppColors.error
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                            fontSize: 14,
                            fontWeight: _isHovered
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
