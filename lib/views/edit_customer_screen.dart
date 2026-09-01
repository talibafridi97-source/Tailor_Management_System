import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      final oldPhone = widget.customerData['phone'];
      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newAddress = _addressController.text.trim();

      await FirebaseFirestore.instance.collection('customers').doc(widget.docId).update({
        'name': newName,
        'phone': newPhone,
        'address': newAddress,
        'gender': _selectedGender,
        'measurements': _measurements,
      });

      // Sync with orders
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('phone', isEqualTo: oldPhone)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in ordersQuery.docs) {
        batch.update(doc.reference, {
          'clientName': newName,
          'phone': newPhone,
          'address': newAddress,
          'gender': _selectedGender,
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text("Customer Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
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
                    _buildField(_addressController, "Address", Icons.location_on, Colors.green, maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_measurements.isNotEmpty) ...[
                const Text("Saved Measurements (Nap)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _measurements.length,
                    itemBuilder: (context, index) {
                      String key = _measurements.keys.elementAt(index);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(key, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            Text("${_measurements[key]} inch", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 30),
              _updateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, Color color, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
