import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/inventory_provider.dart';
import '../controllers/settings_controller.dart';
import '../core/app_translations.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final locale = settings.locale.languageCode;
    String t(String key) => AppTranslations.getText(key, locale);

    final List<String> categories = ["All", "Fabric", "Buttons", "Thread", "Lace", "Bukram", "Other"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
          ),
        ),
        title: Text(t('inventory'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => context.read<InventoryProvider>().fetchItems(), 
            icon: const Icon(Icons.refresh, color: Colors.white)
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(t),
          _buildCategoryFilter(categories, t),
          Expanded(child: _buildInventoryList(t)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemSheet(context, t),
        backgroundColor: const Color(0xFF0056D2),
        label: Text(t('add_stock'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(String Function(String) t) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A2E),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: t('search_stock'),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true, fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> cats, String Function(String) t) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          String cat = cats[index];
          String display = (cat == "All") ? t('all') : t(cat.toLowerCase());
          bool isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0056D2) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [if(!isSelected) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
              ),
              child: Center(child: Text(display, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(String Function(String) t) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var items = provider.items.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final cat = item['category'] ?? '';
          return name.contains(_searchQuery) && (_selectedCategory == "All" || cat == _selectedCategory);
        }).toList();

        if (items.isEmpty) return const Center(child: Text("No items found"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index];
            return _inventoryCard(data, t);
          },
        );
      },
    );
  }

  Widget _inventoryCard(Map<String, dynamic> data, String Function(String) t) {
    String id = data['_id'] ?? data['id'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: ListTile(
        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(t((data['category'] ?? 'other').toString().toLowerCase())),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${data['quantity']} ${data['unit']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(id, data['name'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<InventoryProvider>().deleteItem(id);
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showItemSheet(BuildContext context, String Function(String) t) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    String cat = "Fabric";
    String unit = "Meters";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t('add_stock'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Item Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Quantity", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: InputDecoration(labelText: "Unit", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                      items: ["Meters", "Yards", "Pieces", "Rolls"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setSheetState(() => unit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: cat,
                decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                items: ["Fabric", "Buttons", "Thread", "Lace", "Bukram", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setSheetState(() => cat = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () async {
                    if (nameController.text.isEmpty || qtyController.text.isEmpty) return;
                    final success = await context.read<InventoryProvider>().addItem(nameController.text, qtyController.text, unit, cat);
                    if (mounted && success) Navigator.pop(ctx);
                  },
                  child: const Text("Save Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
