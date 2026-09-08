import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_provider.dart';
import '../controllers/order_provider.dart';

class EditCustomerScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> customerData;

  const EditCustomerScreen({super.key, required this.docId, required this.customerData});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedGender;
  Map<String, dynamic> _measurements = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customerData['name']);
    _phoneController = TextEditingController(text: widget.customerData['phone']);
    _addressController = TextEditingController(text: widget.customerData['address']);
    _selectedGender = widget.customerData['gender'] ?? 'male';
    _measurements = Map<String, dynamic>.from(widget.customerData['measurements'] ?? {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final orderProv = context.read<OrderProvider>();
      final success = await context.read<CustomerProvider>().updateCustomer(
        widget.docId, 
        {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'gender': _selectedGender,
        },
        orderProv
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Customer updated successfully!"), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed. Check backend."), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Customer?"),
        content: Text("Are you sure you want to delete '${widget.customerData['name']}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final orderProv = context.read<OrderProvider>();
              final success = await context.read<CustomerProvider>().deleteCustomer(widget.docId, orderProv);
              if (mounted) {
                Navigator.pop(ctx);
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Customer Removed"), backgroundColor: Colors.redAccent));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
        title: const Text("Edit Customer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmDelete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Basic Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    _buildField(_nameController, "Full Name", Icons.person, Colors.blue),
                    const SizedBox(height: 16),
                    _buildField(_phoneController, "Phone Number", Icons.phone, Colors.red, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _infoField(_addressController, "Address", Icons.location_on, Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _updateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, Color color, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _infoField(TextEditingController controller, String label, IconData icon, Color color) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _updateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateCustomer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0056D2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Update Customer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
