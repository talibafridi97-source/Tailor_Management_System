import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  // Local IP updated to 192.168.10.20
  static const String baseUrl = 'http://192.168.10.20:5000/api/orders';

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

      print("CREATE ORDER STATUS: ${response.statusCode}");
      final dynamic data = _safeDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'message': 'Server Error ${response.statusCode}: ${data is Map ? data['message'] : 'Check Backend'}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrdersVerbose() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Please Logout and Login again (Token Missing)'};
      }

      print("DEBUG: Fetching from -> $baseUrl");
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("DEBUG: Status Code -> ${response.statusCode}");

      // Agar HTML milay (yaani 404 ya crash)
      if (response.body.toLowerCase().contains('<!doctype html>') || 
          response.body.toLowerCase().contains('<html>')) {
        print("CRITICAL: Backend returned HTML. Check if GET route exists.");
        return {
          'success': false, 
          'message': 'Backend Error (${response.statusCode}): Received HTML. \n\nCheck if GET route is defined in Node.js'
        };
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> ordersList = [];
        
        if (decoded is List) {
          ordersList = decoded;
        } else if (decoded is Map) {
          ordersList = decoded['data'] ?? decoded['orders'] ?? decoded['allOrders'] ?? [];
        }
        
        return {'success': true, 'data': ordersList};
      } else {
        return {'success': false, 'message': 'Server returned ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<dynamic>> getOrders() async {
    final res = await getOrdersVerbose();
    return res['success'] ? res['data'] : [];
  }

  static dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      return null;
    }
  }

  // Baqi methods (Update/Delete) wese hi rahenge
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
    } catch (e) {
      return {'success': false};
    }
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
      final response = await http.delete(Uri.parse('$baseUrl/$orderId'), headers: {
          'Authorization': 'Bearer $token',
        });
      return {'success': response.statusCode == 200};
    } catch (e) { return {'success': false}; }
  }
}
