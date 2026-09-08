import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingCount => _orders.where((o) => o['status']?.toString().toLowerCase() == 'pending').length;
  int get completeCount => _orders.where((o) => o['status']?.toString().toLowerCase() == 'complete').length;
  double get totalDueAmount => _orders.fold(0.0, (sum, o) => sum + (double.tryParse(o['dueAmount']?.toString() ?? '0') ?? 0.0));

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await OrderService.getOrdersVerbose();
      if (result['success']) {
        _orders = result['data'] ?? [];
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    String? karigarName,
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
      karigarName: karigarName,
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

  Future<bool> updateKarigar(String orderId, String karigarName) async {
    final result = await OrderService.updateKarigar(orderId, karigarName);
    if (result['success']) {
      // Fast Local Update: Update the name in the current list without re-fetching
      final index = _orders.indexWhere((o) => (o['_id'] ?? o['id']) == orderId);
      if (index != -1) {
        _orders[index]['karigarName'] = karigarName;
        notifyListeners();
      }
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
