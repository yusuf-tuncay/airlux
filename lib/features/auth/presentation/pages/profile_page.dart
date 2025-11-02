import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';

/// Profil sayfası
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _selectedIndex = 3;
  final ImagePicker _imagePicker = ImagePicker();
  String? _cachedPhotoUrl;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
    final authState = ref.watch(authStateProvider);
    final isMobile = Responsive.isMobile(context);

    return ResponsiveScaffold(
      title: null,
      bottomNavIndex: _selectedIndex,
      onBottomNavTap: _onNavTap,
      body: CustomScrollView(
        slivers: [
          authState.when(
            data: (user) => SliverList(
              delegate: SliverChildListDelegate([
                // Profile Info Card
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 32,
                    isMobile ? 20 : 28,
                    isMobile ? 20 : 32,
                    24,
                  ),
                  child: _buildProfileCard(user, isMobile),
                ),

                // Statistics Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                  ),
                  child: _buildStatisticsSection(isMobile),
                ),

                const SizedBox(height: 24),

                // Personal Information Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                  ),
                  child: _buildPersonalInfoSection(user, isMobile),
                ),

                const SizedBox(height: 24),

                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 32,
                    0,
                    isMobile ? 20 : 32,
                    32,
                  ),
                  child: _buildQuickActionsSection(isMobile),
                ),
              ]),
            ),
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldMedium),
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: $error',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                      ),
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

  Widget _buildProfileCard(user, bool isMobile) {
    // Cache'i güncelle
    if (user?.photoUrl != null) {
      _cachedPhotoUrl = user!.photoUrl;
    }
    
    // Debug: URL'yi kontrol et
    if (user?.photoUrl != null) {
      debugPrint('Profile Photo URL: ${user!.photoUrl}');
    }
    
    final photoUrl = user?.photoUrl ?? _cachedPhotoUrl;
    
    return Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderMedium.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldMedium.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Photo with Gradient Border
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldMedium,
                        AppColors.gold,
                        AppColors.goldDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldMedium.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: photoUrl != null
                      ? CircleAvatar(
                          radius: isMobile ? 56 : 64,
                          backgroundColor: AppColors.backgroundCard,
                          backgroundImage: NetworkImage(
                            '$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                          ),
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Image load error: $exception');
                            // Hata durumunda cache'i temizle
                            setState(() {
                              _cachedPhotoUrl = null;
                            });
                          },
                        )
                      : CircleAvatar(
                          radius: isMobile ? 56 : 64,
                          backgroundColor: AppColors.backgroundCard,
                          child: Icon(
                            Icons.person_rounded,
                            size: isMobile ? 56 : 64,
                            color: AppColors.goldMedium,
                          ),
                        ),
                ),
                // Edit Button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: isMobile ? 36 : 40,
                    height: isMobile ? 36 : 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.goldMedium,
                          AppColors.gold,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundCard,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldMedium.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                      onPressed: () => _pickAndUploadImage(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Name
            Text(
              user?.name ?? 'Kullanıcı',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (user?.phone != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user!.phone!,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // Edit Profile Button
            _buildGradientButton(
              label: 'Profili Düzenle',
              icon: Icons.edit_rounded,
              onTap: () {
                // TODO: Profil düzenleme sayfası
              },
              isMobile: isMobile,
            ),
          ],
        ),
    );
  }

  Widget _buildStatisticsSection(bool isMobile) {
    // Dummy data - gerçek uygulamada provider'dan gelecek
    final stats = [
      ('Toplam Rezervasyon', '12', Icons.flight_takeoff_rounded),
      ('Toplam Harcama', '\$450K', Icons.attach_money_rounded),
      ('Üyelik Süresi', '8 Ay', Icons.calendar_today_rounded),
      ('Puan', '4.8', Icons.star_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.1 : 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          label: stat.$1,
          value: stat.$2,
          icon: stat.$3,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMedium.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldMedium.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.goldMedium,
              size: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(user, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMedium.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.goldMedium,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Kişisel Bilgiler',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: 'Ad Soyad',
            value: user?.name ?? 'Belirtilmemiş',
            isMobile: isMobile,
          ),
          const Divider(color: AppColors.borderMedium, height: 24),
          _buildInfoRow(
            icon: Icons.email_rounded,
            label: 'E-posta',
            value: user?.email ?? 'Belirtilmemiş',
            isMobile: isMobile,
          ),
          if (user?.phone != null) ...[
            const Divider(color: AppColors.borderMedium, height: 24),
            _buildInfoRow(
              icon: Icons.phone_rounded,
              label: 'Telefon',
              value: user!.phone!,
              isMobile: isMobile,
            ),
          ],
          const Divider(color: AppColors.borderMedium, height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Üyelik Tarihi',
            value: 'Ocak 2024', // Dummy data
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.goldMedium.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.goldMedium,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(bool isMobile) {
    final actions = [
      (
        'Rezervasyonlarım',
        Icons.book_rounded,
        () => context.go(RouteNames.bookings),
      ),
      (
        'Ayarlar',
        Icons.settings_rounded,
        () => context.go(RouteNames.settings),
      ),
      (
        'Yardım & Destek',
        Icons.help_outline_rounded,
        () {
          // TODO: Yardım sayfası
        },
      ),
      (
        'Gizlilik Politikası',
        Icons.privacy_tip_outlined,
        () {
          // TODO: Gizlilik politikası
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActionCard(
                label: action.$1,
                icon: action.$2,
                onTap: action.$3,
                isMobile: isMobile,
              ),
            )),
      ],
    );
  }

  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderMedium.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldMedium.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.goldMedium,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 32,
            vertical: isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.goldMedium,
                AppColors.gold,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldMedium.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    // Fotoğraf seçme seçenekleri göster
    final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: AppColors.backgroundCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.goldMedium),
                title: const Text(
                  'Kameradan Çek',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.goldMedium),
                title: const Text(
                  'Galeriden Seç',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Fotoğraf seç
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      if (!mounted) return;

      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldMedium),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fotoğraf yükleniyor...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Fotoğrafı yükle (timeout ile)
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.uploadProfilePhoto(
          image.path,
          xFile: image,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Fotoğraf yükleme işlemi zaman aşımına uğradı');
          },
        );

        if (!mounted) return;

        // Loading dialog'u kapat
        Navigator.of(context).pop();

        // Kısa bir gecikme ekle - state'in güncellenmesi için
        await Future.delayed(const Duration(milliseconds: 200));

        if (!mounted) return;

        // State'i kontrol et
        final updatedState = ref.read(authStateProvider);
        if (updatedState.hasError) {
          // Hata varsa göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${updatedState.error}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        // State'i zorla güncelle
        if (updatedState.value?.photoUrl != null) {
          setState(() {
            _cachedPhotoUrl = updatedState.value!.photoUrl;
          });
        }

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil fotoğrafı başarıyla güncellendi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        // Dialog'u kapat
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
  }
}
