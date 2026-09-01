import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Replace with MongoDB equivalent
// import 'package:firebase_auth/firebase_auth.dart'; // TODO: Replace with MongoDB Auth
import 'add_customer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildDashboardContent("current_user_id", context),
    );
  }

  Widget _buildDashboardContent(String uid, BuildContext context) {
    // TODO: Replace with MongoDB data fetch
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _statCard("Total Baqaya (Receivable)", Icons.account_balance_wallet, Colors.red, "Rs. 0.0", ""),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _miniStat("Pending", 0, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat("Complete", 0, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniStat("Delivered", 0, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat("Total Items", 0, Colors.purple)),
            ],
          ),
          const SizedBox(height: 30),
          const Align(alignment: Alignment.centerLeft, child: Text("Customer List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          const Center(child: Text("TODO: Connect MongoDB Customer List", style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 30),
          _actionCard(context, "Add New Customer", Icons.person_add, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()))),
        ],
      ),
    );
  }

  Widget _customerCard(BuildContext context, String id, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFF5F7FA), child: Icon(Icons.person, color: Color(0xFF1A1A2E), size: 20)),
        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(data['phone'] ?? '', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: () => _deleteCustomerDialog(context, id, data['name'] ?? 'this customer'),
        ),
      ),
    );
  }

  void _deleteCustomerDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete $name?"),
        content: const Text("Are you sure? This will remove the customer profile permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              // TODO: Implement MongoDB Delete logic
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
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
