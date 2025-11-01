import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences helper class
class PreferencesHelper {
  static const String _keyRememberEmail = 'remember_email';
  static const String _keyRememberMe = 'remember_me';

  /// Kaydedilmiş email'i al
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberEmail);
  }

  /// Email'i kaydet
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRememberEmail, email);
  }

  /// Email'i sil
  static Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberEmail);
  }

  /// Remember me durumunu al
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Remember me durumunu kaydet
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
  }

  /// Tüm remember me verilerini temizle
  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberEmail);
    await prefs.remove(_keyRememberMe);
  }
}

