import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences helper class
class PreferencesHelper {
  static const String _keyRememberEmail = 'remember_email';
  static const String _keyRememberPassword = 'remember_password';
  static const String _keyRememberName = 'remember_name';
  static const String _keyRememberMe = 'remember_me';

  /// Kaydedilmiş email'i al
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    // Web'de en güncel verileri almak için reload yap
    await prefs.reload();
    return prefs.getString(_keyRememberEmail);
  }

  /// Email'i kaydet
  static Future<void> saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_keyRememberEmail, email);
      if (!result) {
        throw Exception('Email kaydedilemedi');
      }
      // Web'de commit işlemi için reload yap
      await prefs.reload();
      debugPrint('✅ Email localStorage\'a commit edildi: $email');
    } catch (e) {
      throw Exception('Email kaydetme hatası: $e');
    }
  }

  /// Email'i sil
  static Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberEmail);
  }

  /// Kaydedilmiş şifreyi al
  static Future<String?> getRememberedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    // Web'de en güncel verileri almak için reload yap
    await prefs.reload();
    return prefs.getString(_keyRememberPassword);
  }

  /// Şifreyi kaydet
  static Future<void> savePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_keyRememberPassword, password);
      if (!result) {
        throw Exception('Şifre kaydedilemedi');
      }
      // Web'de commit işlemi için reload yap
      await prefs.reload();
      debugPrint('✅ Şifre localStorage\'a commit edildi');
    } catch (e) {
      throw Exception('Şifre kaydetme hatası: $e');
    }
  }

  /// Şifreyi sil
  static Future<void> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberPassword);
  }

  /// Kaydedilmiş ismi al
  static Future<String?> getRememberedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberName);
  }

  /// İsmi kaydet
  static Future<void> saveName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_keyRememberName, name);
      if (!result) {
        throw Exception('İsim kaydedilemedi');
      }
      // Web'de commit işlemi için reload yap
      await prefs.reload();
      debugPrint('✅ İsim localStorage\'a commit edildi: $name');
    } catch (e) {
      throw Exception('İsim kaydetme hatası: $e');
    }
  }

  /// İsmi sil
  static Future<void> clearName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberName);
  }

  /// Remember me durumunu al
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    // Web'de en güncel verileri almak için reload yap
    await prefs.reload();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Remember me durumunu kaydet
  static Future<void> setRememberMe(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(_keyRememberMe, value);
      if (!result) {
        throw Exception('Remember me durumu kaydedilemedi');
      }
      // Web'de commit işlemi için reload yap
      await prefs.reload();
      debugPrint('✅ Remember Me localStorage\'a commit edildi: $value');
    } catch (e) {
      throw Exception('Remember me kaydetme hatası: $e');
    }
  }

  /// Tüm remember me verilerini temizle
  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberEmail);
    await prefs.remove(_keyRememberPassword);
    await prefs.remove(_keyRememberName);
    await prefs.remove(_keyRememberMe);
  }

  /// Tüm kaydedilmiş verileri debug için göster
  static Future<void> debugPrintAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Önce reload yap ki localStorage'dan en güncel verileri al
    await prefs.reload();
    
    final allKeys = prefs.getKeys();
    debugPrint('📦 SharedPreferences tüm anahtarlar: $allKeys');
    debugPrint('📦 Anahtar sayısı: ${allKeys.length}');
    
    // Her anahtarı tek tek kontrol et
    for (final key in allKeys) {
      final value = prefs.get(key);
      debugPrint('   🔑 $key: ${value != null ? (value.toString().length > 50 ? "${value.toString().substring(0, 50)}..." : value.toString()) : "null"}');
    }
    
    final email = await getRememberedEmail();
    final password = await getRememberedPassword();
    final name = await getRememberedName();
    final rememberMe = await getRememberMe();
    
    debugPrint('📧 Email (getRememberedEmail): $email');
    debugPrint('🔑 Şifre (getRememberedPassword): ${password != null ? "${password.length} karakter" : "null"}');
    debugPrint('👤 İsim (getRememberedName): $name');
    debugPrint('✓ Remember Me (getRememberMe): $rememberMe');
    
    // Doğrudan prefs üzerinden de kontrol et
    final directEmail = prefs.getString(_keyRememberEmail);
    final directPassword = prefs.getString(_keyRememberPassword);
    final directName = prefs.getString(_keyRememberName);
    final directRememberMe = prefs.getBool(_keyRememberMe);
    
    debugPrint('📧 Email (direct): $directEmail');
    debugPrint('🔑 Şifre (direct): ${directPassword != null ? "${directPassword.length} karakter" : "null"}');
    debugPrint('👤 İsim (direct): $directName');
    debugPrint('✓ Remember Me (direct): $directRememberMe');
  }
}

