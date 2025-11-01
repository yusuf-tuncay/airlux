import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/firebase/firebase_service.dart';

/// Telefon numarası giriş ve doğrulama sayfası
/// Google ile giriş yapan kullanıcılardan telefon numarası istenir ve SMS ile doğrulanır
class PhoneNumberPage extends ConsumerStatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  ConsumerState<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends ConsumerState<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeSent = false;
  String? _verificationId;
  String? _formattedPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Telefon numarasını formatla (E.164 formatı)
  String _formatPhoneNumber(String phone) {
    // Boşluk ve özel karakterleri temizle
    String cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    
    // + ile başlamıyorsa Türkiye kodu ekle
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('0')) {
        // 0 ile başlıyorsa 0'ı kaldır ve +90 ekle
        cleaned = '+90${cleaned.substring(1)}';
      } else if (cleaned.startsWith('90')) {
        // 90 ile başlıyorsa + ekle
        cleaned = '+$cleaned';
      } else {
        // Diğer durumlarda +90 ekle
        cleaned = '+90$cleaned';
      }
    }
    
    return cleaned;
  }

  /// SMS kodu gönder
  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    _formattedPhone = _formatPhoneNumber(phone);
    final user = FirebaseService.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go(RouteNames.login);
      }
      return;
    }

    try {
      debugPrint('📱 Telefon numarası formatlandı: $_formattedPhone');
      
      // Telefon numarasına SMS kodu gönder
      // Web için Firebase otomatik olarak reCAPTCHA gösterecek
      await FirebaseService.auth.verifyPhoneNumber(
        phoneNumber: _formattedPhone!,
        verificationCompleted: (credential) async {
          // Otomatik doğrulama (genellikle sadece Android'de çalışır)
          debugPrint('✅ Otomatik doğrulama başarılı (sadece Android)');
        },
        verificationFailed: (e) {
          debugPrint('❌ Doğrulama hatası detayları:');
          debugPrint('   Code: ${e.code}');
          debugPrint('   Message: ${e.message}');
          debugPrint('   StackTrace: ${e.stackTrace}');
          
          if (mounted) {
            setState(() => _isLoading = false);
            String errorMessage = 'Doğrulama kodu gönderilemedi';
            
            // Hata kodlarına göre Türkçe mesajlar
            switch (e.code) {
              case 'billing-not-enabled':
                errorMessage = 'Telefon doğrulaması için Firebase faturalandırma hesabının etkinleştirilmesi gerekiyor. Lütfen Firebase Console\'da Billing hesabını etkinleştirin.';
                break;
              case 'invalid-phone-number':
                errorMessage = 'Geçersiz telefon numarası formatı. Lütfen +90 ile başlayan format kullanın.';
                break;
              case 'too-many-requests':
                errorMessage = 'Çok fazla istek. Lütfen daha sonra tekrar deneyin.';
                break;
              case 'operation-not-allowed':
                errorMessage = 'Telefon doğrulaması etkin değil. Lütfen Firebase Console\'da Phone Authentication\'ı etkinleştirin.';
                break;
              case 'quota-exceeded':
                errorMessage = 'SMS kotası aşıldı. Lütfen daha sonra tekrar deneyin.';
                break;
              case 'captcha-check-failed':
                errorMessage = 'reCAPTCHA doğrulaması başarısız. Lütfen tekrar deneyin.';
                break;
              case 'missing-phone-number':
                errorMessage = 'Telefon numarası eksik.';
                break;
              default:
                // Hata mesajını daha detaylı göster
                if (e.message != null && e.message!.isNotEmpty) {
                  errorMessage = 'Doğrulama kodu gönderilemedi: ${e.message}';
                } else {
                  errorMessage = 'Doğrulama kodu gönderilemedi: ${e.code}';
                }
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        codeSent: (verificationId, resendToken) {
          debugPrint('✅ SMS kodu gönderildi. Verification ID: $verificationId');
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isCodeSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Doğrulama kodu gönderildi. Lütfen SMS\'inizi kontrol edin.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          debugPrint('⏱️ Kod otomatik alma zaman aşımı. Verification ID: $verificationId');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
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

  /// SMS kodunu doğrula ve telefon numarasını kaydet
  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğrulama kodunu giriniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseService.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go(RouteNames.login);
      }
      return;
    }

    try {
      // SMS kodunu doğrula
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );

      // Kullanıcının telefon numarasını güncelle
      await user.updatePhoneNumber(credential);

      // Firestore'da telefon numarasını kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'phoneNumber': _formattedPhone,
        'phoneNumberVerified': true,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefon numaranız başarıyla doğrulandı!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Home'a yönlendir
        context.go(RouteNames.home);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage = 'Doğrulama başarısız';
        
        switch (e.code) {
          case 'invalid-verification-code':
            errorMessage = 'Geçersiz doğrulama kodu. Lütfen tekrar deneyin.';
            break;
          case 'session-expired':
            errorMessage = 'Doğrulama kodu süresi doldu. Lütfen yeni kod isteyin.';
            break;
          default:
            errorMessage = 'Doğrulama başarısız: ${e.message ?? e.code}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  /// Telefon numarası validasyonu
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur';
    }

    // Türkiye telefon numarası formatı: +90 veya 0 ile başlamalı
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Geçerli bir Türkiye telefon numarası giriniz\nÖrn: +90 555 123 45 67 veya 0555 123 45 67';
    }

    return null;
  }

  /// SMS kodu validasyonu
  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Doğrulama kodu zorunludur';
    }

    if (value.trim().length != 6) {
      return 'Doğrulama kodu 6 haneli olmalıdır';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Doğrulama kodu sadece rakamlardan oluşmalıdır';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo ve Başlık
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            // Logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldButtonGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldMedium.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.phone_android,
                                size: 40,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Başlık
                            Text(
                              _isCodeSent ? 'Doğrulama Kodu' : 'Telefon Numaranız',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isCodeSent
                                  ? 'SMS ile gönderilen 6 haneli kodu giriniz'
                                  : 'Devam etmek için telefon numaranızı giriniz',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Telefon Numarası Input (Sadece kod gönderilmediyse göster)
                      if (!_isCodeSent) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.goldMedium.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Telefon Numarası',
                              hintText: '+90 555 123 45 67',
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: AppColors.gold,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.gold,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: _validatePhone,
                          ),
                        ),
                      ],

                      // SMS Kodu Input (Kod gönderildiyse göster)
                      if (_isCodeSent) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.goldMedium.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            enabled: !_isLoading,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Doğrulama Kodu',
                              hintText: '123456',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.gold,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.gold,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                letterSpacing: 8,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              counterText: '',
                            ),
                            validator: _validateCode,
                          ),
                        ),
                      ],

                      // Butonlar
                      if (!_isCodeSent)
                        // Kodu Gönder Butonu
                        Container(
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
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendVerificationCode,
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
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.gold,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Kodu Gönder',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        )
                      else
                        // Doğrula Butonu ve Geri Butonu
                        Column(
                          children: [
                            Container(
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
                                      ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verifyCode,
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
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.gold,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Doğrula',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isCodeSent = false;
                                        _verificationId = null;
                                        _codeController.clear();
                                      });
                                    },
                              child: const Text(
                                'Numarayı Değiştir',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
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
    );
  }
}
