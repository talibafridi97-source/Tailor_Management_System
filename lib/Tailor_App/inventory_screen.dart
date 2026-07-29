import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _categories = ["All", "Fabric", "Buttons", "Thread", "Lace", "Bukram", "Other"];
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
          ),
        ),
        title: const Text("Stock Inventory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilter(),
          Expanded(child: _buildInventoryList(user.uid)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemSheet(context),
        backgroundColor: const Color(0xFF0056D2),
        label: const Text("Add New Stock", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
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
          hintText: "Search fabric, buttons, threads...",
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0056D2) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              child: Center(
                child: Text(_categories[index], 
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('inventory').where('userId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        var items = snapshot.data?.docs ?? [];
        
        // Manual Sorting: Newest at the bottom
        items.sort((a, b) {
          final d1 = a.data() as Map<String, dynamic>;
          final d2 = b.data() as Map<String, dynamic>;
          final t1 = d1['timestamp'] as Timestamp?;
          final t2 = d2['timestamp'] as Timestamp?;
          if (t1 == null) return 1; 
          if (t2 == null) return -1;
          return t1.compareTo(t2);
        });

        // Search and Category Filter
        items = items.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final cat = data['category'] ?? '';
          return name.contains(_searchQuery) && (_selectedCategory == "All" || cat == _selectedCategory);
        }).toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("Inventory is empty", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;
            final id = items[index].id;
            return _inventoryListTile(id, data);
          },
        );
      },
    );
  }

  Widget _inventoryListTile(String id, Map<String, dynamic> data) {
    int qty = int.tryParse(data['quantity'].toString()) ?? 0;
    bool isLow = qty < 5;
    Color catColor = _getCatColor(data['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: () => _showDetailsDialog(id, data),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: catColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(_getCatIcon(data['category']), size: 30, color: catColor),
        ),
        title: Text(data['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['category'] ?? 'Other', style: TextStyle(color: catColor, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("$qty ${data['unit'] ?? 'pcs'}", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.blueGrey.shade800)),
                if (isLow) ...[
                  const SizedBox(width: 8),
                  _lowStockBadge(),
                ]
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') _showItemSheet(context, id: id, existingData: data);
            if (val == 'delete') _deleteItem(id);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  Widget _lowStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: const Text("LOW", style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  void _deleteItem(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("Are you sure you want to remove this item from stock?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () {
            FirebaseFirestore.instance.collection('inventory').doc(id).delete();
            Navigator.pop(ctx);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showDetailsDialog(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_getCatIcon(data['category']), color: _getCatColor(data['category'])),
            const SizedBox(width: 10),
            const Text("Stock Details"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Name", data['name']),
            _detailRow("Category", data['category']),
            _detailRow("Quantity", "${data['quantity']} ${data['unit']}"),
            if (data['timestamp'] != null)
              _detailRow("Added On", (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showItemSheet(context, id: id, existingData: data);
            }, 
            child: const Text("Update")
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String l, String? v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: "$l: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: v ?? '-'),
        ]
      )),
    );
  }

  Color _getCatColor(String? c) {
    switch (c) {
      case "Fabric": return Colors.deepPurple;
      case "Buttons": return Colors.orange;
      case "Thread": return Colors.blue;
      case "Lace": return Colors.pink;
      case "Bukram": return Colors.teal;
      default: return Colors.blueGrey;
    }
  }

  IconData _getCatIcon(String? c) {
    switch (c) {
      case "Fabric": return Icons.texture;
      case "Buttons": return Icons.radio_button_checked;
      case "Thread": return Icons.line_weight;
      case "Lace": return Icons.border_style;
      case "Bukram": return Icons.layers;
      default: return Icons.category_outlined;
    }
  }

  void _showItemSheet(BuildContext context, {String? id, Map<String, dynamic>? existingData}) {
    final name = TextEditingController(text: existingData?['name']);
    final qty = TextEditingController(text: existingData?['quantity']?.toString());
    String cat = existingData?['category'] ?? "Fabric";
    String unit = existingData?['unit'] ?? "Meters";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(id == null ? "Add New Stock" : "Update Stock", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            TextField(controller: name, decoration: _inputDeco("Item Name (e.g. White Silk)", Icons.shopping_bag)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: TextField(controller: qty, keyboardType: TextInputType.number, decoration: _inputDeco("Quantity", Icons.numbers))),
                const SizedBox(width: 15),
                Expanded(child: DropdownButtonFormField<String>(value: unit, items: ["Meters", "Yards", "Pieces", "Rolls"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => unit = v!, decoration: _inputDeco("Unit", Icons.straighten))),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: cat, 
              items: _categories.where((c) => c != "All").map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
              onChanged: (v) => cat = v!, 
              decoration: _inputDeco("Category", Icons.category)
            ),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () async {
                if (name.text.isEmpty || qty.text.isEmpty) return;
                final data = {
                  'userId': FirebaseAuth.instance.currentUser!.uid, 
                  'name': name.text, 
                  'quantity': int.tryParse(qty.text) ?? 0, 
                  'category': cat, 
                  'unit': unit, 
                  'timestamp': existingData?['timestamp'] ?? FieldValue.serverTimestamp()
                };
                
                try {
                  if (id == null) {
                    await FirebaseFirestore.instance.collection('inventory').add(data);
                  } else {
                    await FirebaseFirestore.instance.collection('inventory').doc(id).update(data);
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Stock Saved Successfully!"), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: Text(id == null ? "Add to Inventory" : "Update Item", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String l, IconData i) {
    return InputDecoration(
      labelText: l,
      prefixIcon: Icon(i, size: 20, color: const Color(0xFF0056D2)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
