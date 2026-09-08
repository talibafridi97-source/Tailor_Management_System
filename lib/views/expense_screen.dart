import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_provider.dart';
import '../controllers/order_provider.dart';
import '../core/date_formatter.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]))),
        title: const Text("Hisab Kitab (Profit/Loss)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildProfitDashboard(),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text("Recent Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(child: _buildExpenseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(context),
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Kharcha", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProfitDashboard() {
    return Consumer2<OrderProvider, ExpenseProvider>(
      builder: (context, orderProv, expProv, child) {
        double totalRevenue = orderProv.orders.fold(0.0, (sum, o) => sum + (double.tryParse(o['totalBill']?.toString() ?? '0') ?? 0.0));
        double totalExpense = expProv.totalExpense;
        double netProfit = totalRevenue - totalExpense;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem("Total Kamai", "Rs. ${totalRevenue.toInt()}", Colors.greenAccent),
                  _statItem("Total Kharcha", "Rs. ${totalExpense.toInt()}", Colors.redAccent),
                ],
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.white10),
              const SizedBox(height: 15),
              const Text("ASLI MUNAFA (NET PROFIT)", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 5),
              Text(
                "Rs. ${netProfit.toInt()}",
                style: TextStyle(
                  color: netProfit >= 0 ? Colors.blueAccent : Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _statItem(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 5),
        Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExpenseList() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.expenses.isEmpty) return const Center(child: Text("Abhi tak koi kharcha add nahi kiya."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) {
            final e = provider.expenses[index];
            final String id = e['_id'] ?? e['id'] ?? '';
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.remove_circle_outline, color: Colors.red)),
                title: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormatter.format(e['date'])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("- Rs. ${e['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        if (val == 'edit') _showExpenseDialog(context, id: id, existingData: e);
                        if (val == 'delete') _confirmDelete(id, e['title'] ?? '');
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Expense?"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await context.read<ExpenseProvider>().deleteExpense(id);
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, {String? id, Map<String, dynamic>? existingData}) {
    final titleController = TextEditingController(text: existingData?['title']);
    final amountController = TextEditingController(text: existingData?['amount']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(id == null ? "Dukan ka Kharcha Dalein" : "Kharcha Update Karain"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Kharcha kis cheez ka hai?")),
            const SizedBox(height: 10),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rakam (Rs.)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || amountController.text.isEmpty) return;
              bool success;
              if (id == null) {
                success = await context.read<ExpenseProvider>().addExpense(titleController.text, double.parse(amountController.text), "General");
              } else {
                success = await context.read<ExpenseProvider>().updateExpense(id, titleController.text, double.parse(amountController.text));
              }
              if (mounted && success) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), foregroundColor: Colors.white),
            child: Text(id == null ? "Save Karain" : "Update Karain"),
          ),
        ],
      ),
    );
  }
}
