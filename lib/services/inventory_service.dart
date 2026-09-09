import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class InventoryService {
  static const String baseUrl = 'http://192.168.10.16:5000/api/inventory';

  static Future<List<dynamic>> getItems() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addItem(Map<String, dynamic> data) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return {'success': response.statusCode == 201, 'data': jsonDecode(response.body)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> deleteItem(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
