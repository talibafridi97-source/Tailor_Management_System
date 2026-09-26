import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String _ip = '192.168.10.4';

  static String get ip => _ip;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('server_ip') ?? '192.168.10.4';
  }

  static Future<void> setIp(String newIp) async {
    _ip = newIp.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ip);
  }

  static String get orders => 'http://$ip:5000/api/orders';
  static String get customers => 'http://$ip:5000/api/customers';
  static String get expenses => 'http://$ip:5000/api/expenses';
  static String get inventory => 'http://$ip:5000/api/inventory';
  static String get profile => 'http://$ip:5000/api/auth/profile';
  static String get login => 'http://$ip:5000/api/auth/login';
  static String get register => 'http://$ip:5000/api/auth/register';
}
