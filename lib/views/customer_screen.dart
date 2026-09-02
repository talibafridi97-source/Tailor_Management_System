import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_provider.dart';
import 'add_customer_screen.dart';
import 'edit_customer_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

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
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
          ),
        ),
        title: const Text("Customer Directory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A2E),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search customer...",
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(child: _buildCustomerList()),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var filteredCustomers = provider.customers;
        if (_searchQuery.isNotEmpty) {
          filteredCustomers = filteredCustomers.where((c) => 
            (c['name'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
            (c['phone'] ?? '').toString().contains(_searchQuery)
          ).toList();
        }

        if (filteredCustomers.isEmpty) {
          return const Center(child: Text("No customers found", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredCustomers.length,
          itemBuilder: (context, index) {
            final data = filteredCustomers[index];
            return _customerCard(context, data['_id'] ?? '', data);
          },
        );
      },
    );
  }

  Widget _customerCard(BuildContext context, String docId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(child: Text(data['name']?[0]?.toUpperCase() ?? '?')),
        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data['phone'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditCustomerScreen(docId: docId, customerData: data))),
        ),
      ),
    );
  }
}
