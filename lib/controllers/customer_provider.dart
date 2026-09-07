import 'package:flutter/material.dart';
import '../services/customer_service.dart';

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
        print("PROVIDER: Loaded ${_customers.length} customers");
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

  Future<bool> addCustomer({
    required String name,
    required String phone,
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
      await fetchCustomers(); // Reload all
      return true;
    }
    return false;
  }

  Future<bool> deleteCustomer(String id) async {
    final success = await CustomerService.deleteCustomer(id);
    if (success) {
      // Sahi respond milne par list se foran remove karo (Local Sync)
      _customers.removeWhere((c) => (c['_id'] ?? c['id']) == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}
