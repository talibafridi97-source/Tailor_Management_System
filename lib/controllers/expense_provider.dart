import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<dynamic> _expenses = [];
  bool _isLoading = false;

  List<dynamic> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalExpense => _expenses.fold(0.0, (sum, e) => sum + (double.tryParse(e['amount'].toString()) ?? 0.0));

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await ExpenseService.getExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense(String title, double amount, String category) async {
    final success = await ExpenseService.addExpense(title, amount, category);
    if (success) await fetchExpenses();
    return success;
  }
}
