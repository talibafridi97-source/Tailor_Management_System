import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/order_provider.dart';
import '../controllers/customer_provider.dart';
import '../core/app_translations.dart';

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

  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  bool _isUrgent = false;
  bool _isLoading = false;

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
          // Shirt Part
          {"label": "Shirt Length", "icon": Icons.straighten},
          {"label": "Shoulder", "icon": Icons.settings_ethernet},
          {"label": "Chest", "icon": Icons.accessibility_new},
          {"label": "Sleeve Length", "icon": Icons.height},
          {"label": "Collar", "icon": Icons.watch},
          // Pant Part
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
      _controllers[label] = TextEditingController(text: widget.initialMeasurements?[label]?.toString() ?? "");
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
                  _urgentToggle(t),
                  _paymentCard(),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Measurements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _urgentToggle(String Function(String) t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: SwitchListTile(
        title: Text(t('mark_urgent'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        secondary: const Icon(Icons.push_pin, color: Colors.redAccent),
        value: _isUrgent,
        activeColor: Colors.redAccent,
        onChanged: (val) => setState(() => _isUrgent = val),
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _totalPriceController, keyboardType: TextInputType.number, decoration: _inputDeco("Total Bill", Icons.payments))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _advanceController, keyboardType: TextInputType.number, decoration: _inputDeco("Advance", Icons.account_balance_wallet))),
        ],
      ),
    );
  }

  Widget _materialsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: _materialControllers.keys.map((k) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _materialControllers[k],
            decoration: _inputDeco(k, Icons.texture),
          ),
        )).toList(),
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.garment, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
          _dateTile("Order Date", _orderDate, true),
          const Divider(),
          _dateTile("Delivery Date", _deliveryDate, false),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, bool isOrder) {
    return ListTile(
      title: Text(label),
      trailing: Text("${date.day}/${date.month}/${date.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2035));
        if (picked != null) setState(() => isOrder ? _orderDate = picked : _deliveryDate = picked);
      },
    );
  }

  Widget _measurementInput(Map<String, dynamic> m) {
    return TextField(
      controller: _controllers[m["label"]],
      keyboardType: TextInputType.number,
      decoration: _inputDeco(m["label"], m["icon"]),
    );
  }

  Widget _saveAction() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity, height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);

    try {
      double total = double.tryParse(_totalPriceController.text) ?? 0.0;
      double adv = double.tryParse(_advanceController.text) ?? 0.0;
      double due = total - adv;

      Map<String, String> mData = {};
      _controllers.forEach((k, v) => mData[k] = v.text);

      List<String> materials = [];
      _materialControllers.forEach((k, v) {
        if (v.text.isNotEmpty) materials.add("$k: ${v.text}");
      });

      // Call Providers
      final customerProvider = context.read<CustomerProvider>();
      final orderProvider = context.read<OrderProvider>();

      final custSaved = await customerProvider.addCustomer(
        name: widget.clientName,
        phone: widget.phone,
        address: widget.address,
        measurements: mData,
      );

      final orderSaved = await orderProvider.addOrder(
        clientName: widget.clientName,
        phone: widget.phone,
        garment: widget.garment,
        measurements: mData,
        materials: materials,
        totalBill: total,
        advancePayment: adv,
        dueAmount: due,
        orderDate: _orderDate,
        deliveryDate: _deliveryDate,
        isPinned: _isUrgent,
      );

      if (mounted) {
        if (custSaved && orderSaved) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Saved Successfully!"), backgroundColor: Colors.green));
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          String errorDetail = orderProvider.errorMessage ?? "Server connection failed";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $errorDetail"), backgroundColor: Colors.red, duration: const Duration(seconds: 4))
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDeco(String l, IconData i) {
    return InputDecoration(
      labelText: l, prefixIcon: Icon(i),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true, fillColor: Colors.white,
    );
  }
}
