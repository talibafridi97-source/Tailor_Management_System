import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/api_config.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _billController = TextEditingController();
  final _advanceController = TextEditingController();
  final _tidController = TextEditingController();
  
  String _selectedGarment = 'Shalwar Kameez';
  final Map<String, List<String>> _garmentMeasurements = {
    'Shalwar Kameez': ['Kameez Length', 'Chest', 'Shoulder', 'Sleeves', 'Shalwar Length', 'Paincha', 'Collar'],
    'Pant Shirt': ['Shirt Length', 'Chest', 'Shoulder', 'Sleeves', 'Pant Waist', 'Pant Length', 'Hip'],
    'Coat': ['Coat Length', 'Chest', 'Waist', 'Shoulder', 'Sleeves', 'Armhole'],
    'Kurta Pajama': ['Kurta Length', 'Chest', 'Shoulder', 'Sleeves', 'Pajama Length', 'Bottom'],
    'Sherwani': ['Sherwani Length', 'Chest', 'Waist', 'Shoulder', 'Sleeves', 'Collar'],
  };

  final Map<String, TextEditingController> _measurementControllers = {};

  @override
  void initState() {
    super.initState();
    for (var garment in _garmentMeasurements.keys) {
      for (var field in _garmentMeasurements[garment]!) {
        _measurementControllers[field] = TextEditingController();
      }
    }
  }

  bool _isLoading = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final totalBill = double.tryParse(_billController.text.trim()) ?? 0.0;
      final advance = double.tryParse(_advanceController.text.trim()) ?? 0.0;
      final due = totalBill - advance;

      final fields = _garmentMeasurements[_selectedGarment] ?? [];
      final measurements = <String, String>{};
      for (var field in fields) {
        measurements[field] = _measurementControllers[field]?.text.trim() ?? '';
      }

      // Public Customer Order endpoint pointing to Live Render Backend
      const url = 'https://tailor-app-backend-tign.onrender.com/api/customer/orders';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clientName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'garment': _selectedGarment,
          'measurements': measurements,
          'totalBill': totalBill,
          'advancePayment': advance,
          'dueAmount': due,
          'deliveryDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'transactionId': _tidController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text("Order Submitted! 🎉"),
              ],
            ),
            content: const Text("Your order & payment TID have been sent successfully to the tailor shop with notification sound!"),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(ctx);
                  _formKey.currentState!.reset();
                  _nameController.clear();
                  _phoneController.clear();
                  _billController.clear();
                  _advanceController.clear();
                  _tidController.clear();
                  for (var controller in _measurementControllers.values) {
                    controller.clear();
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit order: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _billController.dispose();
    _advanceController.dispose();
    _tidController.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDynamicMeasurements() {
    final fields = _garmentMeasurements[_selectedGarment] ?? [];
    return Column(
      children: [
        for (int i = 0; i < fields.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _measurementControllers[fields[i]],
                    decoration: InputDecoration(
                      labelText: fields[i],
                      prefixIcon: const Icon(Icons.straighten, color: Colors.orangeAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.orange.shade50.withOpacity(0.3),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                if (i + 1 < fields.length)
                  Expanded(
                    child: TextFormField(
                      controller: _measurementControllers[fields[i + 1]],
                      decoration: InputDecoration(
                        labelText: fields[i + 1],
                        prefixIcon: const Icon(Icons.straighten, color: Colors.orangeAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.orange.shade50.withOpacity(0.3),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Tailor Shop - Online Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F3460), Color(0xFF16213E), Color(0xFF1A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colorful Banner Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0056D2), Color(0xFF4A90E2), Color(0xFF00C853)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cut, size: 42, color: Colors.white),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Custom Tailoring Portal ✂️", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Select garment, pay via Easypaisa/JazzCash, & submit measurements instantly!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Share Buttons for Shop Owner
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0056D2),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF0056D2), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text("Copy Link", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: () {
                        const link = 'https://tailormanagement-570e5.web.app';
                        Clipboard.setData(const ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Live Web Link copied to clipboard!"), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text("Share WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: () async {
                        const link = 'https://tailormanagement-570e5.web.app';
                        final message = Uri.encodeComponent("Assalam-o-Alaikum! Aap is link par click karke apne measurements aur custom order online submit kar sakte hain:\n$link");
                        final whatsappUrl = Uri.parse("https://wa.me/?text=$message");
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                        } else {
                          Clipboard.setData(const ClipboardData(text: link));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Link copied! WhatsApp could not be opened directly."), backgroundColor: Colors.orange),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Customer Details Card
              _buildSectionCard(
                title: "1. Customer Information & Garment",
                icon: Icons.person_pin,
                color: Colors.blueAccent,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blue.shade50.withOpacity(0.3),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blue.shade50.withOpacity(0.3),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedGarment,
                    decoration: InputDecoration(
                      labelText: "Select Garment Type",
                      prefixIcon: const Icon(Icons.checkroom, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blue.shade50.withOpacity(0.3),
                    ),
                    items: _garmentMeasurements.keys.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (v) => setState(() => _selectedGarment = v!),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dynamic Measurements Card
              _buildSectionCard(
                title: "2. Measurements for $_selectedGarment (in inches)",
                icon: Icons.straighten,
                color: Colors.orangeAccent,
                children: [
                  _buildDynamicMeasurements(),
                ],
              ),
              const SizedBox(height: 20),

              // Payment Card
              _buildSectionCard(
                title: "3. Estimated Payment",
                icon: Icons.payments,
                color: Colors.green,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _billController,
                          decoration: InputDecoration(
                            labelText: "Estimated Bill (Rs)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.green.shade50.withOpacity(0.3),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _advanceController,
                          decoration: InputDecoration(
                            labelText: "Advance Paid (Rs)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.green.shade50.withOpacity(0.3),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Easypaisa / JazzCash Payment Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.deepOrange, size: 26),
                        SizedBox(width: 10),
                        Text("Online Payment (Easypaisa / JazzCash)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                    const Divider(height: 18),
                    const Text("Please send advance payment to the following account:", style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Easypaisa / JazzCash", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text("Account: 03439246597 (Talib Nawaz)", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _tidController,
                      decoration: InputDecoration(
                        labelText: "Enter Transaction ID (TID) if paid (Optional)",
                        prefixIcon: const Icon(Icons.receipt_long, color: Colors.deepOrange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Submit Online Order 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
