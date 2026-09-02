import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_provider.dart';
import '../controllers/customer_provider.dart';
import 'add_customer_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          ),
        ),
        title: const Text("Business Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<OrderProvider, CustomerProvider>(
        builder: (context, orderProv, custProv, child) {
          if (orderProv.isLoading || custProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statCard("Total Baqaya", Icons.account_balance_wallet, Colors.red, "Rs. ${orderProv.totalDueAmount.toInt()}", ""),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _miniStat("Pending", orderProv.pendingCount, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _miniStat("Complete", orderProv.completeCount, Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _miniStat("Total Customers", custProv.customers.length, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _miniStat("Total Orders", orderProv.orders.length, Colors.purple)),
                  ],
                ),
                const SizedBox(height: 30),
                _actionCard(context, "Add New Customer", Icons.person_add, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        children: [
          Text("$val", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, Color color, String val, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15)]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
