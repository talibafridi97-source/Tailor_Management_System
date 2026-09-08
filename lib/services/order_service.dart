import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.10.24:5000/api/orders';

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
    String? karigarName,
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
          'karigarName': karigarName,
          'status': 'pending', 
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Server Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrdersVerbose() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token Missing. Please Login again.'};
      }

      print("FETCHING ORDERS FROM: $baseUrl");
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print("ORDERS STATUS: ${response.statusCode}");

      if (response.body.toLowerCase().contains('<!doctype html>')) {
        return {'success': false, 'message': 'Backend Error: Received HTML instead of Data.'};
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> ordersList = [];
        
        if (decoded is List) {
          ordersList = decoded;
        } else if (decoded is Map) {
          ordersList = decoded['data'] ?? decoded['orders'] ?? [];
        }
        
        print("LOADED ${ordersList.length} ORDERS");
        return {'success': true, 'data': ordersList};
      } else {
        return {'success': false, 'message': 'Server returned status ${response.statusCode}'};
      }
    } catch (e) {
      print("ORDER FETCH EXCEPTION: $e");
      return {'success': false, 'message': 'Connection Error. Is your Laptop/Server reachable?'};
    }
  }

  static Future<List<dynamic>> getOrders() async {
    final res = await getOrdersVerbose();
    return res['success'] ? res['data'] : [];
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
      return {'success': response.statusCode == 200};
    } catch (e) { return {'success': false}; }
  }

  static Future<Map<String, dynamic>> updateKarigar(String orderId, String karigarName) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'karigarName': karigarName}),
      );
      return {'success': response.statusCode == 200};
    } catch (e) { return {'success': false}; }
  }

  static Future<Map<String, dynamic>> updatePayment(String orderId, double totalBill) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(Uri.parse('$baseUrl/$orderId'), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }, body: jsonEncode({'advancePayment': totalBill, 'dueAmount': 0}));
      return {'success': response.statusCode == 200};
    } catch (e) { return {'success': false}; }
  }

  static Future<Map<String, dynamic>> deleteOrder(String orderId) async {
    try {
      final token = await AuthService.getToken();
      print("DEBUG: Deleting Order -> $baseUrl/$orderId");
      final response = await http.delete(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: Delete Result Status -> ${response.statusCode}");
      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'message': response.statusCode == 404 ? "Route not found on Backend" : "Server Error"
      };
    } catch (e) {
      print("DEBUG: Delete Exception -> $e");
      return {'success': false, 'message': e.toString()};
    }
  }
}
