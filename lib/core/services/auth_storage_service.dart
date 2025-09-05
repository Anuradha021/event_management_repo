import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const _kToken = 'auth_token';
  static const _kRole = 'auth_role';
  static const _kName = 'auth_name';
  static const _kEmail = 'auth_email';
  static const _kUserId = 'auth_user_id';

  static Future<void> saveSession({
  required String token,
  required String role,
  String? name,
  String? email,
  String? userId,
}) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_kToken, token.trim());
  await sp.setString(_kRole, role.toUpperCase());

  if (name != null) await sp.setString(_kName, name);
  if (email != null) await sp.setString(_kEmail, email);
  if (userId != null) await sp.setString(_kUserId, userId);
}

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  static Future<String?> getCurrentUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUserId);
  }

  static Future<String?> getName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kName);
  }

  static Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

  static Future<bool> isAdmin() async =>
      (await getRole())?.toUpperCase() == 'ADMIN';

  static Future<bool> isSystemAdmin() async =>
      (await getRole())?.toUpperCase() == 'SYSTEM_ADMIN';

  static Future<bool> isOrganizer() async =>
      (await getRole())?.toUpperCase() == 'ORGANIZER';

  static Future<bool> isUser() async =>
      (await getRole())?.toUpperCase() == 'USER';
}