import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerService {
  static const String baseUrl = 'http://192.168.10.24:5000/api/customers';

  // 1. Add New Customer
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

  // 2. Fetch All Customers
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
      ).timeout(const Duration(seconds: 15));

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
        return {'success': false, 'message': 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error'};
    }
  }

  // 3. Update Customer (New)
  static Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return {'success': response.statusCode == 200, 'data': jsonDecode(response.body)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 4. Delete Customer
  static Future<bool> deleteCustomer(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
