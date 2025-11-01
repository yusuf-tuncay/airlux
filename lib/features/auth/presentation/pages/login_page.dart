import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/preferences_helper.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../providers/auth_provider.dart';

/// Login ekranı
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 LoginPage initState çağrıldı');
    debugPrint('🔵 Widget key: ${widget.key}');

    // Önce SharedPreferences'ı kontrol et - HEMEN başlat
    _loadRememberedEmail();

    // Eğer Firebase session açıksa ve remember me varsa, otomatik giriş yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  /// Otomatik giriş kontrolü
  Future<void> _checkAutoLogin() async {
    try {
      final user = FirebaseService.currentUser;
      final rememberMe = await PreferencesHelper.getRememberMe();
      final rememberedEmail = await PreferencesHelper.getRememberedEmail();
      final rememberedPassword =
          await PreferencesHelper.getRememberedPassword();

      debugPrint('🔄 Otomatik giriş kontrolü:');
      debugPrint('   👤 Firebase User: ${user != null ? "Var" : "Yok"}');
      debugPrint('   ✓ Remember Me: $rememberMe');
      debugPrint(
        '   📧 Remembered Email: ${rememberedEmail != null ? "Var" : "Yok"}',
      );
      debugPrint(
        '   🔑 Remembered Password: ${rememberedPassword != null ? "Var" : "Yok"}',
      );

      // Eğer Firebase'de giriş yapmışsa ve remember me açıksa, home'a git
      if (user != null && rememberMe && mounted) {
        debugPrint('✅ Otomatik giriş yapılıyor - Home\'a yönlendiriliyor');
        // Kısa bir gecikme ekle ki veriler yüklensin
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.go(RouteNames.home);
        }
      } else if (user == null &&
          rememberMe &&
          rememberedEmail != null &&
          rememberedPassword != null &&
          mounted) {
        // Eğer Firebase'de giriş yapmamışsa ama remember me verileri varsa, otomatik giriş yap
        debugPrint('🔄 Remember me verileri var, otomatik giriş deneniyor...');
        _autoLogin();
      }
    } catch (e) {
      debugPrint('❌ Otomatik giriş kontrolü hatası: $e');
    }
  }

  /// Otomatik giriş yap
  Future<void> _autoLogin() async {
    try {
      final rememberedEmail = await PreferencesHelper.getRememberedEmail();
      final rememberedPassword =
          await PreferencesHelper.getRememberedPassword();

      if (rememberedEmail == null || rememberedPassword == null || !mounted) {
        return;
      }

      debugPrint('🔐 Otomatik giriş başlatılıyor: $rememberedEmail');
      setState(() => _isLoading = true);

      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signInWithEmail(
        email: rememberedEmail,
        password: rememberedPassword,
      );

      // State güncellenmesini bekle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      authState.when(
        data: (user) {
          if (user != null && mounted) {
            debugPrint('✅ Otomatik giriş başarılı!');
            context.go(RouteNames.home);
          }
        },
        error: (error, stackTrace) {
          debugPrint('❌ Otomatik giriş başarısız: $error');
          setState(() => _isLoading = false);
        },
        loading: () {
          // Loading durumunda bekle
        },
      );
    } catch (e) {
      debugPrint('❌ Otomatik giriş hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kaydedilmiş bilgileri yükle
  Future<void> _loadRememberedEmail() async {
    debugPrint('🔵 _loadRememberedEmail çağrıldı');
    try {
      // Tüm SharedPreferences verilerini göster (debug için)
      await PreferencesHelper.debugPrintAll();

      final rememberedEmail = await PreferencesHelper.getRememberedEmail();
      final rememberedPassword =
          await PreferencesHelper.getRememberedPassword();
      final rememberMe = await PreferencesHelper.getRememberMe();

      debugPrint('🔍 Kaydedilmiş bilgiler kontrol ediliyor...');
      debugPrint('   📧 Email: $rememberedEmail');
      debugPrint(
        '   🔑 Şifre: ${rememberedPassword != null ? "${rememberedPassword.length} karakter" : "yok"}',
      );
      debugPrint('   ✓ Remember Me: $rememberMe');
      debugPrint('   📱 Widget mounted: $mounted');

      if (!mounted) {
        debugPrint('⚠️ Widget unmounted, veriler yüklenmeyecek');
        return;
      }

      if (rememberMe) {
        debugPrint('✅ Remember me aktif, veriler yükleniyor...');
        bool emailLoaded = false;
        bool passwordLoaded = false;

        if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
          _emailController.text = rememberedEmail;
          emailLoaded = true;
          debugPrint('   ✅ Email yüklendi: $rememberedEmail');
        } else {
          debugPrint('   ❌ Email null veya boş');
        }

        if (rememberedPassword != null && rememberedPassword.isNotEmpty) {
          _passwordController.text = rememberedPassword;
          passwordLoaded = true;
          debugPrint(
            '   ✅ Şifre yüklendi: ${rememberedPassword.length} karakter',
          );
        } else {
          debugPrint('   ❌ Şifre null veya boş');
        }

        setState(() {
          _rememberMe = true;
        });

        debugPrint('   ✅ Remember Me checkbox işaretlendi');

        if (emailLoaded || passwordLoaded) {
          debugPrint('✅ Bilgiler başarıyla yüklendi ve setState çağrıldı');
        } else {
          debugPrint('⚠️ Hiçbir veri yüklenemedi');
        }
      } else {
        debugPrint('ℹ️ Remember me kapalı, veriler yüklenmeyecek');
        setState(() {
          _rememberMe = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Remember bilgileri yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final rememberMe = _rememberMe;

    // DEBUG: Remember me değerini kontrol et
    debugPrint('🔐 Giriş yapılıyor:');
    debugPrint('   📧 Email: $email');
    debugPrint('   🔑 Şifre: ${password.length} karakter');
    debugPrint('   ✓ Remember Me: $rememberMe');

    final authNotifier = ref.read(authStateProvider.notifier);

    try {
      await authNotifier.signInWithEmail(email: email, password: password);

      // State güncellenmesini bekle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // State'i kontrol et
      final authState = ref.read(authStateProvider);

      // Başarılı giriş kontrolü
      authState.when(
        data: (user) async {
          if (user != null && mounted) {
            setState(() => _isLoading = false);

            // Beni Hatırla işlemi - ÖNCE KAYDET, SONRA NAVIGATE ET
            if (rememberMe) {
              debugPrint('💾 Remember me AÇIK - Veriler kaydediliyor...');
              try {
                // Tüm bilgileri TEK TEK kaydet (Web'de daha güvenilir)
                debugPrint('   💾 Email kaydediliyor...');
                await PreferencesHelper.saveEmail(email);
                debugPrint('   ✅ Email kaydedildi');

                debugPrint('   💾 Şifre kaydediliyor...');
                await PreferencesHelper.savePassword(password);
                debugPrint('   ✅ Şifre kaydedildi');

                debugPrint('   💾 Remember Me durumu kaydediliyor...');
                await PreferencesHelper.setRememberMe(true);
                debugPrint('   ✅ Remember Me kaydedildi');

                // İsim varsa ekle
                if (user.name != null && user.name!.isNotEmpty) {
                  debugPrint('   💾 İsim kaydediliyor...');
                  await PreferencesHelper.saveName(user.name!);
                  debugPrint('   ✅ İsim kaydedildi');
                }

                debugPrint('✅ Tüm kaydetme işlemleri tamamlandı (tek tek)');

                // Kayıtları doğrula (hemen kontrol et)
                await PreferencesHelper.debugPrintAll();

                // Kaydedilen değerleri tekrar oku ve doğrula
                final savedEmail = await PreferencesHelper.getRememberedEmail();
                final savedPassword =
                    await PreferencesHelper.getRememberedPassword();
                final savedRememberMe = await PreferencesHelper.getRememberMe();

                debugPrint('📋 Kaydedilen değerler doğrulandı:');
                debugPrint('   📧 Saved Email: $savedEmail (beklenen: $email)');
                debugPrint(
                  '   🔑 Saved Password: ${savedPassword != null ? "${savedPassword.length} karakter" : "null"} (beklenen: ${password.length} karakter)',
                );
                debugPrint(
                  '   ✓ Saved Remember Me: $savedRememberMe (beklenen: true)',
                );

                if (savedEmail == email &&
                    savedPassword == password &&
                    savedRememberMe == true) {
                  debugPrint(
                    '✅ Tüm veriler başarıyla kaydedildi ve doğrulandı!',
                  );
                } else {
                  debugPrint(
                    '⚠️ Veri doğrulama başarısız! Beklenen değerler kaydedilmemiş olabilir.',
                  );
                }

                debugPrint('✅ Bilgiler başarıyla kaydedildi:');
                debugPrint('   📧 Email: $email');
                debugPrint('   🔑 Şifre: ${password.length} karakter');
                debugPrint('   👤 İsim: ${user.name ?? "yok"}');
                debugPrint('   ✓ Remember Me: true');

                // Kısa bir gecikme ekle (SharedPreferences'ın commit edilmesi için)
                await Future.delayed(const Duration(milliseconds: 500));

                // Final kontrol - tekrar oku ve doğrula
                debugPrint(
                  '🔍 Final kontrol - localStorage\'dan tekrar okuyoruz...',
                );
                await PreferencesHelper.debugPrintAll();

                // Kaydetme başarılı olduktan SONRA navigate et
                if (mounted) {
                  context.go(RouteNames.home);
                }
              } catch (e) {
                debugPrint('❌ Bilgiler kaydedilirken hata: $e');
                // Hata olsa bile navigate et
                if (mounted) {
                  context.go(RouteNames.home);
                }
              }
            } else {
              // Remember me kapalıysa temizle (async beklemeden)
              PreferencesHelper.clearRememberMe().then((_) {
                debugPrint('🗑️ Remember me verileri temizlendi');
              });

              // Navigate et
              if (mounted) {
                context.go(RouteNames.home);
              }
            }
          }
        },
        loading: () async {
          // Hala yükleniyorsa, state güncellenene kadar bekle
          debugPrint('⏳ Auth state yükleniyor...');

          // Biraz daha bekle ve tekrar kontrol et
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          final updatedState = ref.read(authStateProvider);
          updatedState.when(
            data: (user) async {
              if (user != null && mounted) {
                setState(() => _isLoading = false);

                // Beni Hatırla işlemi - ÖNCE KAYDET, SONRA NAVIGATE ET
                if (rememberMe) {
                  try {
                    final saveOperations = <Future>[
                      PreferencesHelper.saveEmail(email),
                      PreferencesHelper.savePassword(password),
                      PreferencesHelper.setRememberMe(true),
                    ];

                    if (user.name != null && user.name!.isNotEmpty) {
                      saveOperations.add(
                        PreferencesHelper.saveName(user.name!),
                      );
                    }

                    // Kaydetme işleminin tamamlanmasını bekle
                    await Future.wait(saveOperations);
                    debugPrint('✅ Bilgiler başarıyla kaydedildi (retry):');
                    debugPrint('   📧 Email: $email');
                  } catch (e) {
                    debugPrint('❌ Bilgiler kaydedilirken hata (retry): $e');
                  }
                }

                // Navigate et
                if (mounted) {
                  context.go(RouteNames.home);
                }
              }
            },
            loading: () {
              // Hala yükleniyor, hatayı göster
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş işlemi zaman aşımına uğradı'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            error: (error, stackTrace) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Giriş başarısız: $error'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          );
        },
        error: (error, stackTrace) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giriş başarısız: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final authNotifier = ref.read(authStateProvider.notifier);

    try {
      await authNotifier.signInWithGoogle();

      // State güncellenmesini bekle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // State'i kontrol et
      final authState = ref.read(authStateProvider);

      // Başarılı giriş kontrolü
      authState.when(
        data: (user) async {
          if (user != null && mounted) {
            setState(() => _isLoading = false);
            debugPrint('✅ Google girişi başarılı: ${user.email}');

            // NOT: Telefon numarası kontrolü GEÇİCİ OLARAK KALDIRILDI
            // Kullanıcı doğrudan home'a yönlendiriliyor
            // Telefon numarası girmek isteyenler telefon numarası sayfasına manuel olarak gidebilir
            if (mounted) {
              context.go(RouteNames.home);
            }
          }
        },
        loading: () async {
          // Hala yükleniyorsa, state güncellenene kadar bekle
          debugPrint('⏳ Google auth state yükleniyor...');

          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          final updatedState = ref.read(authStateProvider);
          updatedState.when(
            data: (user) async {
              if (user != null && mounted) {
                setState(() => _isLoading = false);

                // NOT: Telefon numarası kontrolü GEÇİCİ OLARAK KALDIRILDI
                // Kullanıcı doğrudan home'a yönlendiriliyor
                if (mounted) {
                  context.go(RouteNames.home);
                }
              }
            },
            loading: () {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google girişi zaman aşımına uğradı'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            error: (error, stackTrace) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Google girişi başarısız: $error'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          );
        },
        error: (error, stackTrace) {
          if (mounted) {
            setState(() => _isLoading = false);

            // "iptal edildi" hatası ise sessizce geç
            if (error.toString().contains('iptal')) {
              debugPrint('ℹ️ Google girişi kullanıcı tarafından iptal edildi');
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google girişi başarısız: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Premium Logo with Glow Effect
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                blurRadius: 25,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                blurRadius: 50,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppColors
                                .premiumGoldGradient
                                .createShader(bounds),
                            child: const Icon(
                              Icons.flight,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors
                              .premiumGoldGradient
                              .createShader(bounds),
                          child: Text(
                            'Airlux\'a\nHoş Geldiniz',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Devam etmek için giriş yapın',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Email Field - Premium Design
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              labelText: 'E-posta',
                              labelStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.goldMedium,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundCard,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderMedium,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderMedium,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.goldMedium,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen e-posta adresinizi girin';
                              }
                              // Email format validasyonu
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Lütfen geçerli bir e-posta adresi girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password Field - Premium Design
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              labelStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.goldMedium,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.goldMedium,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundCard,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderMedium,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderMedium,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.goldMedium,
                                  width: 2,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen şifrenizi girin';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalıdır';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Beni Hatırla Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.goldMedium,
                              checkColor: AppColors.primaryDark,
                              side: BorderSide(
                                color: AppColors.goldMedium,
                                width: 2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Text(
                                'Beni Hatırla',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Premium Login Button with Gradient
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _isLoading
                                ? null
                                : AppColors.goldButtonGradient,
                            boxShadow: _isLoading
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.goldMedium.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? AppColors.backgroundCard
                                  : Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.goldMedium,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleGoogleLogin,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.goldMedium,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: AppColors.goldMedium,
                            ),
                            label: const Text(
                              'Google ile Giriş Yap',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldMedium,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Premium Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hesabınız yok mu? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(RouteNames.register),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => AppColors
                                    .premiumGoldGradient
                                    .createShader(bounds),
                                child: const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.goldMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
