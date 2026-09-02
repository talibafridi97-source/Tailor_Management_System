import 'package:flutter/material.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<dynamic> _customers = [];
  bool _isLoading = false;

  List<dynamic> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await CustomerService.getCustomers();
    } catch (e) {
      debugPrint("Error fetching customers: $e");
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
      await fetchCustomers(); // Refresh list
      return true;
    }
    return false;
  }
}
