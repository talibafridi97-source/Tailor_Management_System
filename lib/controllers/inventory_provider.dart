import 'package:flutter/material.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  bool _isLoading = false;

  List<dynamic> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await InventoryService.getItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addItem(String name, String quantity, String unit, String category) async {
    final result = await InventoryService.addItem({
      'name': name,
      'quantity': double.tryParse(quantity) ?? 0,
      'unit': unit,
      'category': category,
    });
    if (result['success']) {
      await fetchItems();
      return true;
    }
    return false;
  }

  Future<bool> deleteItem(String id) async {
    final success = await InventoryService.deleteItem(id);
    if (success) {
      _items.removeWhere((item) => (item['_id'] ?? item['id']) == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}
