import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;

  int get pendingCount => _orders.where((o) => o['status']?.toString().toLowerCase() == 'pending').length;
  int get completeCount => _orders.where((o) => o['status']?.toString().toLowerCase() == 'complete').length;
  double get totalDueAmount => _orders.fold(0.0, (sum, o) => sum + (double.tryParse(o['dueAmount']?.toString() ?? '0') ?? 0.0));

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> freshOrders = await OrderService.getOrders();
      _orders = freshOrders;
      print("PROVIDER UPDATED WITH: ${_orders.length} orders");
    } catch (e) {
      debugPrint("PROVIDER FETCH ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOrder({
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
    String status = 'pending',
  }) async {
    final result = await OrderService.createOrder(
      clientName: clientName,
      phone: phone,
      garment: garment,
      measurements: measurements,
      materials: materials,
      totalBill: totalBill,
      advancePayment: advancePayment,
      dueAmount: dueAmount,
      orderDate: orderDate,
      deliveryDate: deliveryDate,
      isPinned: isPinned,
    );

    if (result['success']) {
      await fetchOrders(); 
      return true;
    }
    return false;
  }

  Future<bool> updateStatus(String orderId, String status) async {
    final result = await OrderService.updateOrderStatus(orderId, status);
    if (result['success']) {
      await fetchOrders(); 
      return true;
    }
    return false;
  }

  Future<bool> collectPayment(String orderId, double totalBill) async {
    final result = await OrderService.updatePayment(orderId, totalBill);
    if (result['success']) {
      await fetchOrders();
      return true;
    }
    return false;
  }

  Future<bool> deleteOrder(String orderId) async {
    final result = await OrderService.deleteOrder(orderId);
    if (result['success']) {
      await fetchOrders();
      return true;
    }
    return false;
  }
}
