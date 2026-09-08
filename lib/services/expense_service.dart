import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ExpenseService {
  static const String baseUrl = 'http://192.168.10.24:5000/api/expenses';

  static Future<List<dynamic>> getExpenses() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(Uri.parse(baseUrl), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  static Future<bool> addExpense(String title, double amount, String category) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'title': title, 'amount': amount, 'category': category}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<bool> updateExpense(String id, String title, double amount) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'title': title, 'amount': amount}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> deleteExpense(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}
