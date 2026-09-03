import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerService {
  // Physical Device (Samsung A52) ke liye Local Network IP
  static const String baseUrl = 'http://192.168.10.9:5000/api/customers';

  // 1. Add New Customer (with Measurements)
  static Future<Map<String, dynamic>> addCustomer({
    required String name,
    required String phone,
    String address = '',
    String gender = 'Male',
    required Map<String, dynamic> measurements,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'address': address,
          'gender': gender,
          'measurements': measurements,
        }),
      );

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 201, 'data': data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 2. Fetch All Customers
  static Future<List<dynamic>> getCustomers() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}