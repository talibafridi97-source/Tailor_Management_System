import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_provider.dart';
import '../controllers/settings_controller.dart';
import '../core/app_translations.dart';
import '../core/date_formatter.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          ),
        ),
        title: Text(t('due_payment'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Expanded(child: _buildDueList()),
        ],
      ),
    );
  }

  Widget _buildDueList() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        // Filter only orders with dueAmount > 0
        var dueOrders = provider.orders.where((o) => 
          (double.tryParse(o['dueAmount']?.toString() ?? '0') ?? 0.0) > 0
        ).toList();

        if (_searchQuery.isNotEmpty) {
          dueOrders = dueOrders.where((o) => 
            (o['clientName'] ?? '').toString().toLowerCase().contains(_searchQuery)
          ).toList();
        }

        if (dueOrders.isEmpty) {
          return const Center(child: Text("No pending payments found", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dueOrders.length,
          itemBuilder: (context, index) {
            final data = dueOrders[index];
            return _dueCard(data['_id'] ?? data['id'] ?? '', data);
          },
        );
      },
    );
  }

  Widget _dueCard(String id, Map<String, dynamic> data) {
    double due = double.tryParse(data['dueAmount']?.toString() ?? '0') ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: data, orderId: id))),
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.1),
          child: const Icon(Icons.person, color: Colors.redAccent),
        ),
        title: Text(data['clientName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${data['garment'] ?? ''} • ${DateFormatter.format(data['deliveryDate'])}"),
        trailing: Text("Rs. ${due.toInt()}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}
