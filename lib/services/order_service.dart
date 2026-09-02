import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.10.7:5000/api/orders';

  static Future<Map<String, dynamic>> createOrder({
    required String clientName,
    required String phone,
    required String garment,
    required Map<String, String> measurements,
    required List<String> materials,
    required double totalBill,
    required double advancePayment,
    required double dueAmount,
    required DateTime orderDate,
    required DateTime deliveryDate,
    required bool isPinned,
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
          'clientName': clientName,
          'phone': phone,
          'garment': garment,
          'measurements': measurements,
          'materials': materials,
          'totalBill': totalBill,
          'advancePayment': advancePayment,
          'dueAmount': dueAmount,
          'orderDate': orderDate.toIso8601String(),
          'deliveryDate': deliveryDate.toIso8601String(),
          'isPinned': isPinned,
          'status': 'pending', 
        }),
      );

      print("CREATE ORDER RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 201 || response.statusCode == 200, 'data': data};
    } catch (e) {
      print("CREATE ORDER ERROR: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getOrders() async {
    try {
      final token = await AuthService.getToken();
      print("FETCHING ORDERS WITH TOKEN: ${token?.substring(0, 10)}...");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("GET ORDERS STATUS: ${response.statusCode}");
      print("GET ORDERS BODY: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        if (decoded is List) {
          return decoded;
        } 
        else if (decoded is Map) {
          // Robust checking for common response keys
          return decoded['data'] ?? decoded['orders'] ?? decoded['allOrders'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("GET ORDERS ERROR: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      print("UPDATE STATUS RESPONSE: ${response.body}");
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updatePayment(String orderId, double totalBill) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'advancePayment': totalBill,
          'dueAmount': 0,
        }),
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> deleteOrder(String orderId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }
}
