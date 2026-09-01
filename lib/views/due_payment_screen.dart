import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Replace with MongoDB equivalent
// import 'package:firebase_auth/firebase_auth.dart'; // TODO: Replace with MongoDB Auth
import 'order_detail_screen.dart';

class DuePaymentScreen extends StatefulWidget {
  const DuePaymentScreen({super.key});

  @override
  State<DuePaymentScreen> createState() => _DuePaymentScreenState();
}

class _DuePaymentScreenState extends State<DuePaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text("Baqaya Payments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildDueList("current_user_id")),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search customer name...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildDueList(String uid) {
    // TODO: Replace with MongoDB due payment fetch
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade100),
          const SizedBox(height: 16),
          const Text("TODO: Connect MongoDB Due List", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _dueCard(String id, Map<String, dynamic> data) {
    double due = (data['dueAmount'] ?? 0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: data, orderId: id))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red.withOpacity(0.1),
          child: const Icon(Icons.person, color: Colors.redAccent),
        ),
        title: Text(data['clientName'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['garment'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text("Bill: ${data['totalBill']} | Paid: ${data['advancePayment']}", style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Baqaya", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
            Text("Rs. $due", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
