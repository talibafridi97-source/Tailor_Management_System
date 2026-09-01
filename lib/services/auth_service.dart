import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Token Save
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Token Read
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Local storage cache ko refresh karta hai
    return prefs.getString('jwt_token');
  }

  // Token Remove
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}