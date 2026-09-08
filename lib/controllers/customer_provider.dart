import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import 'order_provider.dart';

class CustomerProvider extends ChangeNotifier {
  List<dynamic> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await CustomerService.getCustomersVerbose();
      if (result['success']) {
        _customers = result['data'] ?? [];
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

  // Method to add and sync
  Future<bool> addCustomer({
    required String name,
    required String phone,
    required OrderProvider orderProv, // Syncing with order provider
    String address = '',
    String gender = 'Male',
    required Map<String, dynamic> measurements,
  }) async {
    final result = await CustomerService.addCustomer(
      name: name,
      phone: phone,
      address: address,
      gender: gender,
      measurements: measurements,
    );

    if (result['success']) {
      await fetchCustomers();
      await orderProv.fetchOrders(); // Sync home screen
      return true;
    }
    return false;
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> data, OrderProvider orderProv) async {
    final result = await CustomerService.updateCustomer(id, data);
    if (result['success']) {
      await fetchCustomers();
      await orderProv.fetchOrders(); // Sync home screen
      return true;
    }
    return false;
  }

  Future<bool> deleteCustomer(String id, OrderProvider orderProv) async {
    final success = await CustomerService.deleteCustomer(id);
    if (success) {
      _customers.removeWhere((c) => (c['_id'] ?? c['id']) == id);
      await orderProv.fetchOrders(); // Sync home screen
      notifyListeners();
      return true;
    }
    return false;
  }
}
