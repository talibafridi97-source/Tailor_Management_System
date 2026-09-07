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
    print("DEBUG: fetchCustomers() started...");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await CustomerService.getCustomersVerbose();
      if (result['success']) {
        _customers = result['data'] ?? [];
        print("DEBUG: Successfully loaded ${_customers.length} customers into Provider");
      } else {
        _errorMessage = result['message'];
        print("DEBUG: fetchCustomers() failed: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("DEBUG: fetchCustomers() Exception: $e");
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
    print("DEBUG: addCustomer() for $name");
    final result = await CustomerService.addCustomer(
      name: name,
      phone: phone,
      address: address,
      gender: gender,
      measurements: measurements,
    );

    if (result['success']) {
      print("DEBUG: Customer added successfully. Refreshing list...");
      await fetchCustomers();
      return true;
    }
    print("DEBUG: addCustomer() failed");
    return false;
  }

  Future<bool> deleteCustomer(String id) async {
    print("DEBUG: Attempting to delete customer with ID: $id");
    if (id.isEmpty) {
       print("DEBUG: Cannot delete, ID is empty!");
       return false;
    }
    
    final success = await CustomerService.deleteCustomer(id);
    if (success) {
      print("DEBUG: Customer deleted successfully. Refreshing list...");
      await fetchCustomers();
      return true;
    }
    print("DEBUG: deleteCustomer() failed on server/network");
    return false;
  }
}
