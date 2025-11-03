import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/preferences_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';

/// Ayarlar sayfası
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Settings sayfası için selectedIndex kullanmıyoruz
  // çünkü BottomNavigationBar'da sadece 4 öğe var (0-3)
  // Settings sidebar navigation'da index 4 olarak görünüyor
  bool _notificationsEnabled = true;
  bool _emailUpdates = false;
  bool _smsNotifications = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final rememberMeValue = await PreferencesHelper.getRememberMe();
    setState(() {
      _rememberMe = rememberMeValue;
    });
  }

  void _onNavTap(int index) {
    // Navigate to corresponding page
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.search);
        break;
      case 2:
        context.go(RouteNames.bookings);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
      case 4:
        context.go(RouteNames.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final authState = ref.watch(authStateProvider);

    return ResponsiveScaffold(
      title: null,
      // Settings sayfası için bottomNavIndex null - mobilde bottom nav gösterme
      // Tablet/Desktop'ta sidebar navigation kullanılıyor (orada index 4 var)
      bottomNavIndex: isMobile
          ? null
          : 4, // Tablet/Desktop için sidebar'da 4. index
      onBottomNavTap: isMobile ? null : _onNavTap,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primaryDarkLight,
                    AppColors.secondaryDark,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 20 : 32,
                      isMobile ? 60 : 80,
                      isMobile ? 20 : 32,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ayarlar',
                          style: TextStyle(
                            fontSize: isMobile ? 32 : 40,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uygulama ayarlarınızı özelleştirin',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings Content
          authState.when(
            data: (user) => user == null
                ? SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 80,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Giriş Yapmanız Gerekiyor',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ayarlara erişmek için\nhesabınıza giriş yapmalısınız',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                context.go(RouteNames.login);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldMedium,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 20 : 32,
                        24,
                        isMobile ? 20 : 32,
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bildirimler
                          _buildSettingsSection(
                            title: 'Bildirimler',
                            icon: Icons.notifications_outlined,
                            children: [
                              _buildSwitchTile(
                                icon: Icons.notifications_active,
                                title: 'Push Bildirimleri',
                                subtitle:
                                    'Yeni rezervasyonlar ve güncellemeler hakkında bildirim al',
                                value: _notificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSwitchTile(
                                icon: Icons.email_outlined,
                                title: 'E-posta Bildirimleri',
                                subtitle: 'E-posta ile güncellemeleri al',
                                value: _emailUpdates,
                                onChanged: (value) {
                                  setState(() {
                                    _emailUpdates = value;
                                  });
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSwitchTile(
                                icon: Icons.sms_outlined,
                                title: 'SMS Bildirimleri',
                                subtitle: 'SMS ile önemli güncellemeleri al',
                                value: _smsNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _smsNotifications = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Hesap
                          _buildSettingsSection(
                            title: 'Hesap',
                            icon: Icons.person_outline,
                            children: [
                              _buildSettingsTile(
                                icon: Icons.person,
                                title: 'Profil Bilgileri',
                                subtitle: 'Ad, soyad ve iletişim bilgileri',
                                onTap: () {
                                  context.go(RouteNames.profile);
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSettingsTile(
                                icon: Icons.lock_outline,
                                title: 'Şifre Değiştir',
                                subtitle: 'Hesap şifrenizi güncelleyin',
                                onTap: () {
                                  _showPasswordChangeDialog();
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSwitchTile(
                                icon: Icons.remember_me_outlined,
                                title: 'Beni Hatırla',
                                subtitle: 'Otomatik giriş yap',
                                value: _rememberMe,
                                onChanged: (value) async {
                                  await PreferencesHelper.setRememberMe(value);
                                  setState(() {
                                    _rememberMe = value;
                                  });
                                  if (!value) {
                                    await PreferencesHelper.clearRememberMe();
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Görünüm
                          _buildSettingsSection(
                            title: 'Görünüm',
                            icon: Icons.palette_outlined,
                            children: [
                              _buildSettingsTile(
                                icon: Icons.dark_mode_outlined,
                                title: 'Karanlık Mod',
                                subtitle: 'Gece modunu aktifleştir',
                                trailing: Icon(
                                  Icons.dark_mode,
                                  color: AppColors.goldMedium,
                                  size: 20,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Karanlık mod yakında eklenecek',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSettingsTile(
                                icon: Icons.language,
                                title: 'Dil',
                                subtitle: 'Türkçe',
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Dil seçenekleri yakında eklenecek',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Uygulama
                          _buildSettingsSection(
                            title: 'Uygulama',
                            icon: Icons.info_outline,
                            children: [
                              _buildSettingsTile(
                                icon: Icons.help_outline,
                                title: 'Yardım & Destek',
                                subtitle: 'SSS ve iletişim bilgileri',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Yardım sayfası yakında eklenecek',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Gizlilik Politikası',
                                subtitle: 'Veri kullanımı ve gizlilik',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gizlilik politikası yakında eklenecek',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSettingsTile(
                                icon: Icons.description_outlined,
                                title: 'Kullanım Koşulları',
                                subtitle: 'Hizmet şartları ve koşullar',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kullanım koşulları yakında eklenecek',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: AppColors.borderMedium,
                                height: 1,
                              ),
                              _buildSettingsTile(
                                icon: Icons.info,
                                title: 'Hakkında',
                                subtitle: 'Uygulama versiyonu ve bilgileri',
                                onTap: () {
                                  _showAboutDialog();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Çıkış Yap Butonu
                          authState.when(
                            data: (user) {
                              if (user == null) return const SizedBox.shrink();
                              return _buildLogoutButton();
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldMedium,
                  ),
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: $error',
                      style: TextStyle(color: AppColors.error, fontSize: 16),
                      textAlign: TextAlign.center,
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

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMedium.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldMedium.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.goldMedium, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldMedium,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.goldMedium.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.goldMedium, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.goldMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.goldMedium.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.goldMedium, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.error, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

    if (confirmed == true && mounted) {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signOut();
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Şifre Değiştir',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Şifre değiştirme özelliği yakında eklenecek.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam', style: TextStyle(color: AppColors.goldMedium)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.goldMedium, AppColors.gold],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.flight, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'AirLux',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versiyon 1.0.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'Lüks özel uçak kiralama deneyimi',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              '© 2025 AirLux',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            Text(
              'Tüm hakları saklıdır.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Kapat', style: TextStyle(color: AppColors.goldMedium)),
          ),
        ],
      ),
    );
  }
}
