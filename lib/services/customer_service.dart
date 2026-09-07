import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerService {
  static const String baseUrl = 'http://192.168.10.20:5000/api/customers';

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
      return {
        'success': response.statusCode == 201 || response.statusCode == 200, 
        'data': data
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 2. Fetch All Customers with Verbose Logging
  static Future<Map<String, dynamic>> getCustomersVerbose() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token Missing'};
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> customers = [];
        
        if (decoded is List) {
          customers = decoded;
        } else if (decoded is Map) {
          customers = decoded['data'] ?? decoded['customers'] ?? [];
        }
        
        return {'success': true, 'data': customers};
      } else {
        return {'success': false, 'message': 'Server Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getCustomers() async {
    final res = await getCustomersVerbose();
    return res['success'] ? res['data'] : [];
  }

  // 3. Delete Customer
  static Future<bool> deleteCustomer(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
