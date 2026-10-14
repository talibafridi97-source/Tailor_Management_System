import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Live Cloud Backend URL on Render.com
  static const String baseUrl = 'https://tailor-app-backend-tign.onrender.com/api';

  static String get orders => '$baseUrl/orders';
  static String get customers => '$baseUrl/customers';
  static String get expenses => '$baseUrl/expenses';
  static String get inventory => '$baseUrl/inventory';
  static String get profile => '$baseUrl/auth/profile';
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';

  static Future<void> init() async {}
  static Future<void> setIp(String newIp) async {}
  static String get ip => 'tailor-app-backend-tign.onrender.com';
}
