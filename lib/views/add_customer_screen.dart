import 'package:flutter/material.dart';
import 'measurement_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  String? _selectedGarment;
  String? _selectedKarigar;

  final List<String> _karigars = ["Self", "Karigar 1", "Karigar 2", "Karigar 3", "Karigar 4", "Karigar 5"];

  final List<Map<String, dynamic>> _garments = [
    {"name": "Shalwar Kameez", "icon": Icons.accessibility_new, "color": const Color(0xFF6C63FF)},
    {"name": "Shirt", "icon": Icons.checkroom, "color": const Color(0xFFFF6B6B)},
    {"name": "Shirt & Pant", "icon": Icons.shopping_bag, "color": const Color(0xFF4ECDC4)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate() && _selectedGender != null && _selectedGarment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeasurementScreen(
            clientName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            gender: _selectedGender!,
            garment: _selectedGarment!,
            // karigarName will be passed or handled in MeasurementScreen
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select Gender & Garment")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]))),
        title: const Text("Add New Customer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(_nameController, "Full Name", Icons.person, const Color(0xFF6C63FF)),
              const SizedBox(height: 16),
              _buildField(_phoneController, "Phone Number", Icons.phone, const Color(0xFFFF6B6B), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField(_addressController, "Address", Icons.location_on, const Color(0xFF4ECDC4), maxLines: 2),
              
              const SizedBox(height: 24),
              const Text("Select Gender", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _genderOption("Male", Icons.male, const Color(0xFF6C63FF)),
                  const SizedBox(width: 12),
                  _genderOption("Female", Icons.female, const Color(0xFFFF6B6B)),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Select Garment (Suit Type)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._garments.map((g) => _garmentOption(g)),

              const SizedBox(height: 30),
              _nextButton(),
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
        counterText: "",
      ),
      validator: (v) {
        if (v!.isEmpty) return "Required";
        if (label.contains("Phone") && v.length < 11) return "Enter 11 digits";
        return null;
      },
    );
  }

  Widget _genderOption(String label, IconData icon, Color color) {
    bool isSelected = _selectedGender == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? color : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSelected ? Colors.white : color, size: 20), const SizedBox(width: 8), Text(label, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _garmentOption(Map<String, dynamic> garment) {
    bool isSelected = _selectedGarment == garment["name"];
    return GestureDetector(
      onTap: () => setState(() => _selectedGarment = garment["name"]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? garment["color"] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? garment["color"] : Colors.grey.shade200)),
        child: Row(children: [Icon(garment["icon"], color: isSelected ? Colors.white : garment["color"]), const SizedBox(width: 16), Text(garment["name"], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)), const Spacer(), if (isSelected) const Icon(Icons.check_circle, color: Colors.white)]),
      ),
    );
  }

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onNext,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: const Text("Next: Take Measurements", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
