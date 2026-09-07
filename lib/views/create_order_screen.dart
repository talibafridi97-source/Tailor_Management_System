import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Replace with MongoDB equivalent
// import 'package:firebase_auth/firebase_auth.dart'; // TODO: Replace with MongoDB Auth
import 'measurement_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  String? _selectedGarment;
  Map<String, dynamic>? _oldMeasurements;
  bool _isFetching = false;

  final List<Map<String, dynamic>> _garments = [
    {"name": "Shalwar Kameez", "icon": Icons.accessibility_new, "color": const Color(0xFF6C63FF)},
    {"name": "Shirt", "icon": Icons.checkroom, "color": const Color(0xFFFF6B6B)},
    {"name": "Shirt & Pant", "icon": Icons.shopping_bag, "color": const Color(0xFF4ECDC4)},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    String phone = _phoneController.text.trim();
    if (phone.length >= 10) _fetchCustomer(phone);
  }

  Future<void> _fetchCustomer(String phone) async {
    // TODO: Implement MongoDB Customer fetch
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _clientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]))),
        title: const Text("Create New Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(_clientNameController, "Full Name", Icons.person, const Color(0xFF6C63FF)),
              const SizedBox(height: 16),
              _buildField(_phoneController, "Phone Number", Icons.phone, const Color(0xFFFF6B6B), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField(_addressController, "Address", Icons.location_on, const Color(0xFF4ECDC4), maxLines: 2),
              const SizedBox(height: 24),
              const Text("Select Gender", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _genderBtn("Male", Icons.male, const Color(0xFF6C63FF)),
                  const SizedBox(width: 12),
                  _genderBtn("Female", Icons.female, const Color(0xFFFF6B6B)),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Select Garment", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._garments.map((g) => _garmentTile(g)),
              const SizedBox(height: 30),
              _nextButton(),
              const SizedBox(height: 20),
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
      maxLength: label.contains("Phone") ? 11 : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
        counterText: "", // Hides the character counter
      ),
      validator: (v) {
        if (v!.isEmpty) return "Required";
        if (label.contains("Phone") && v.length < 11) return "Enter full 11 digits";
        return null;
      },
    );
  }

  Widget _genderBtn(String label, IconData icon, Color color) {
    bool sel = _selectedGender == label.toLowerCase();
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = label.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: sel ? color : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: sel ? Colors.white : color), const SizedBox(width: 8), Text(label, style: TextStyle(color: sel ? Colors.white : color, fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _garmentTile(Map<String, dynamic> g) {
    bool sel = _selectedGarment == g["name"];
    return GestureDetector(
      onTap: () => setState(() => _selectedGarment = g["name"]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: sel ? g["color"] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: sel ? g["color"] : Colors.grey.shade200)),
        child: Row(children: [Icon(g["icon"], color: sel ? Colors.white : g["color"]), const SizedBox(width: 16), Text(g["name"], style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)), const Spacer(), if (sel) const Icon(Icons.check_circle, color: Colors.white)]),
      ),
    );
  }

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate() && _selectedGender != null && _selectedGarment != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MeasurementScreen(
              clientName: _clientNameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              gender: _selectedGender!,
              garment: _selectedGarment!,
              initialMeasurements: _oldMeasurements,
            )));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and select garment")));
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: const Text("Next: Take Measurements", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
