import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // Token Save
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await syncFcmToken(); // Auto sync FCM token on login/signup
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

  // Sync FCM Token to Backend
  static Future<void> syncFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final token = await getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/auth/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      print("FCM Token Sync Status: ${response.statusCode}");
    } catch (e) {
      print("FCM Token Sync Error: $e");
    }
  }
}
