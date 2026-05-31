import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // ── مفاتيح التخزين (Keys) ──
  // نضعها كمتغيرات ثابتة ومخفية لكي لا نخطئ في كتابتها (Typo) في أماكن أخرى
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _emailKey = 'user_email';

  /// 1. دالة لحفظ حالة تسجيل الدخول (نستدعيها عند نجاح تسجيل الدخول)
  static Future<void> saveLoginData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true); // حفظ أن المستخدم سجل دخوله
    await prefs.setString(_emailKey, email);   // حفظ الإيميل كمرجع
  }

  /// 2. دالة لقراءة حالة تسجيل الدخول (نستدعيها في بوابة الدخول AuthGate)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // إذا وجد المفتاح سيعيد قيمته، وإذا كان المستخدم جديداً ولم يسجل من قبل سيعيد false
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// 3. دالة لمسح بيانات الدخول (نستدعيها عند تسجيل الخروج)
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_emailKey);
  }
}