import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementScreen extends StatefulWidget {
  final String clientName;
  final String phone;
  final String address;
  final String gender;
  final String garment;
  final Map<String, dynamic>? initialMeasurements;

  const MeasurementScreen({
    super.key,
    required this.clientName,
    required this.phone,
    required this.address,
    required this.gender,
    required this.garment,
    this.initialMeasurements,
  });

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _materialControllers = {
    'Fabric': TextEditingController(),
    'Buttons': TextEditingController(),
    'Thread': TextEditingController(),
    'Lace': TextEditingController(),
    'Bukram': TextEditingController(),
  };

  // Payment Controllers
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  User? get _user => FirebaseAuth.instance.currentUser;
  DateTime _orderDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));

  List<Map<String, dynamic>> _getMeasurements() {
    switch (widget.garment) {
      case "Shalwar Kameez":
        return [
          {"label": "Kameez Length", "icon": Icons.straighten},
          {"label": "Shoulder", "icon": Icons.settings_ethernet},
          {"label": "Chest", "icon": Icons.accessibility_new},
          {"label": "Waist", "icon": Icons.circle},
          {"label": "Hip", "icon": Icons.circle_outlined},
          {"label": "Sleeve Length", "icon": Icons.height},
          {"label": "Collar", "icon": Icons.watch},
          {"label": "Arm Hole", "icon": Icons.adjust},
          {"label": "Shalwar Length", "icon": Icons.straighten},
          {"label": "Shalwar Bottom", "icon": Icons.circle_outlined},
        ];
      case "Shirt":
        return [
          {"label": "Shirt Length", "icon": Icons.straighten},
          {"label": "Shoulder", "icon": Icons.settings_ethernet},
          {"label": "Chest", "icon": Icons.accessibility_new},
          {"label": "Waist", "icon": Icons.circle},
          {"label": "Sleeve Length", "icon": Icons.height},
          {"label": "Collar", "icon": Icons.watch},
          {"label": "Arm Hole", "icon": Icons.adjust},
        ];
      case "Shirt & Pant":
        return [
          {"label": "Shirt Length", "icon": Icons.straighten},
          {"label": "Shoulder", "icon": Icons.settings_ethernet},
          {"label": "Chest", "icon": Icons.accessibility_new},
          {"label": "Sleeve Length", "icon": Icons.height},
          {"label": "Collar", "icon": Icons.watch},
          {"label": "Pant Length", "icon": Icons.straighten},
          {"label": "Pant Waist", "icon": Icons.circle},
          {"label": "Hip", "icon": Icons.circle_outlined},
          {"label": "Pant Bottom", "icon": Icons.circle_outlined},
        ];
      default:
        return [
          {"label": "Length", "icon": Icons.straighten},
          {"label": "Shoulder", "icon": Icons.settings_ethernet},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    for (var m in _getMeasurements()) {
      String label = m["label"];
      String initialValue = widget.initialMeasurements?[label]?.toString() ?? "";
      _controllers[label] = TextEditingController(text: initialValue);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    for (var c in _materialControllers.values) c.dispose();
    _totalPriceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurements = _getMeasurements();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          ),
        ),
        title: Text("${widget.garment} Nap", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _clientCard(),
                  _datesCard(),
                  _paymentCard(), // Added Payment Card
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Measurements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: measurements.length,
                    itemBuilder: (context, index) {
                      final m = measurements[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _measurementInput(m),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Material Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    ),
                  ),
                  _materialsSection(),
                ],
              ),
            ),
          ),
          _saveAction(),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Due Payment (Hisab)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _totalPriceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("Total Bill (Rs)", Icons.payments),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _advanceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("Advance (Rs)", Icons.account_balance_wallet),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _materialsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          _materialInput("Fabric", Icons.texture, _materialControllers['Fabric']!),
          const SizedBox(height: 12),
          _materialInput("Buttons", Icons.radio_button_checked, _materialControllers['Buttons']!),
          const SizedBox(height: 12),
          _materialInput("Thread", Icons.line_weight, _materialControllers['Thread']!),
          const SizedBox(height: 12),
          _materialInput("Lace", Icons.border_style, _materialControllers['Lace']!),
          const SizedBox(height: 12),
          _materialInput("Bukram", Icons.layers, _materialControllers['Bukram']!),
        ],
      ),
    );
  }

  Widget _materialInput(String label, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0056D2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF0056D2), child: const Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${widget.gender.toUpperCase()} - ${widget.garment}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          _dateTile(Icons.calendar_today, "Order Date", _orderDate, true, const Color(0xFFFF8C00)),
          const Divider(height: 20),
          _dateTile(Icons.event, "Delivery Date", _deliveryDate, false, const Color(0xFF00C853)),
        ],
      ),
    );
  }

  Widget _dateTile(IconData icon, String label, DateTime date, bool isOrder, Color color) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2035));
        if (picked != null) setState(() => isOrder ? _orderDate = picked : _deliveryDate = picked);
      },
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text("${date.day}/${date.month}/${date.year}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _measurementInput(Map<String, dynamic> m) {
    return TextFormField(
      controller: _controllers[m["label"]],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: m["label"],
        prefixIcon: Icon(m["icon"], color: const Color(0xFF6C63FF)),
        suffixText: "inch",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _saveAction() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Confirm & Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final currentUser = _user;
    if (currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      // Payment Calculation
      double total = double.tryParse(_totalPriceController.text) ?? 0.0;
      double adv = double.tryParse(_advanceController.text) ?? 0.0;
      double due = total - adv;

      Map<String, String> mData = {};
      _controllers.forEach((k, v) => mData[k] = v.text);

      Map<String, String> materials = {};
      _materialControllers.forEach((k, v) => materials[k] = v.text);

      final batch = _firestore.batch();
      
      final custQ = await _firestore.collection('customers').where('userId', isEqualTo: currentUser.uid).where('phone', isEqualTo: widget.phone).get();
      if (custQ.docs.isEmpty) {
        batch.set(_firestore.collection('customers').doc(), {
          'userId': currentUser.uid, 'name': widget.clientName, 'phone': widget.phone, 'address': widget.address, 'gender': widget.gender, 'measurements': mData, 'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        batch.update(custQ.docs.first.reference, {'name': widget.clientName, 'address': widget.address, 'measurements': mData});
      }

      batch.set(_firestore.collection('orders').doc(), {
        'userId': currentUser.uid, 
        'clientName': widget.clientName, 
        'phone': widget.phone, 
        'address': widget.address,
        'gender': widget.gender,
        'garment': widget.garment, 
        'measurements': mData, 
        'materials': materials,
        'totalBill': total,
        'advancePayment': adv,
        'dueAmount': due,
        'orderDate': Timestamp.fromDate(_orderDate),
        'deliveryDate': Timestamp.fromDate(_deliveryDate),
        'status': 'pending', 
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Saved with Payment Details!"), backgroundColor: Colors.green));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDeco(String l, IconData i) {
    return InputDecoration(
      labelText: l,
      prefixIcon: Icon(i, size: 20, color: const Color(0xFF0056D2)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}
