class ApiConfig {
  // Pixel 6 Virtual Device (Emulator) ke liye 10.0.2.2 100% permanent aur fix hai!
  static const String ip = '10.0.2.2';

  static Future<void> init() async {}

  static Future<void> setIp(String newIp) async {}

  static String get orders => 'http://$ip:5000/api/orders';
  static String get customers => 'http://$ip:5000/api/customers';
  static String get expenses => 'http://$ip:5000/api/expenses';
  static String get inventory => 'http://$ip:5000/api/inventory';
  static String get profile => 'http://$ip:5000/api/auth/profile';
  static String get login => 'http://$ip:5000/api/auth/login';
  static String get register => 'http://$ip:5000/api/auth/register';
}
