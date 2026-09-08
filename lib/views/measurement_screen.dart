import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/order_provider.dart';
import '../controllers/customer_provider.dart';
import '../core/app_translations.dart';
import '../services/whatsapp_service.dart';

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
  String? _selectedKarigar;
  bool _isUrgent = false;
  bool _isLoading = false;

  final List<String> _karigars = ["Self", "Karigar 1", "Karigar 2", "Karigar 3", "Karigar 4", "Karigar 5"];

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
          {"label": "Pant Length", "icon": Icons.straighten},
          {"label": "Pant Waist", "icon": Icons.circle},
          {"label": "Hip", "icon": Icons.circle_outlined},
        ];
      default:
        return [{"label": "Length", "icon": Icons.straighten}];
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("${widget.garment} Nap", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Customer Details", Icons.person_pin_outlined),
                _clientCard(),
                const SizedBox(height: 20),
                
                _buildSectionHeader("Order Timeline", Icons.calendar_month_outlined),
                _datesCard(),
                const SizedBox(height: 10),
                _urgentToggle(t),
                const SizedBox(height: 20),

                _buildSectionHeader("Assign to Karigar / Worker", Icons.work_outline),
                _karigarSelector(),
                const SizedBox(height: 20),

                _buildSectionHeader("Payment Information", Icons.account_balance_wallet_outlined),
                _paymentCard(),
                const SizedBox(height: 20),

                _buildSectionHeader("Body Measurements", Icons.straighten),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2
                    ),
                    itemCount: measurements.length,
                    itemBuilder: (context, index) => _measurementInput(measurements[index]),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader("Material Provided", Icons.inventory_2_outlined),
                _materialsSection(),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _saveAction()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0056D2).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Color(0xFF0056D2), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.clientName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(widget.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Column(
        children: [
          _dateTile("Order Date", _orderDate, true, Colors.orange),
          const Divider(height: 24),
          _dateTile("Delivery Date", _deliveryDate, false, Colors.green),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, bool isOrder, Color color) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2035));
        if (picked != null) setState(() => isOrder ? _orderDate = picked : _deliveryDate = picked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text("${date.day}/${date.month}/${date.year}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _urgentToggle(String Function(String) t) {
    return Container(
      decoration: BoxDecoration(
        color: _isUrgent ? Colors.red.shade50 : Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: _isUrgent ? Border.all(color: Colors.redAccent, width: 1.5) : null,
      ),
      child: SwitchListTile(
        title: Text(t('urgent'), style: TextStyle(fontWeight: FontWeight.bold, color: _isUrgent ? Colors.red : Colors.black87)),
        secondary: Icon(Icons.push_pin, color: _isUrgent ? Colors.red : Colors.grey),
        value: _isUrgent,
        activeColor: Colors.red,
        onChanged: (val) => setState(() => _isUrgent = val),
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Expanded(child: _modernField(_totalPriceController, "Total Bill", Icons.payments, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _modernField(_advanceController, "Advance", Icons.account_balance_wallet, Colors.green)),
        ],
      ),
    );
  }

  Widget _measurementInput(Map<String, dynamic> m) {
    return TextField(
      controller: _controllers[m["label"]],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: InputDecoration(
        labelText: m["label"],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        prefixIcon: Icon(m["icon"], size: 16, color: const Color(0xFF0056D2)),
        filled: true, fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _materialsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Column(
        children: _materialControllers.keys.map((k) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _modernField(_materialControllers[k]!, k, Icons.texture, Colors.blueGrey),
        )).toList(),
      ),
    );
  }

  Widget _modernField(TextEditingController controller, String label, IconData icon, Color color) {
    return TextField(
      controller: controller,
      keyboardType: label.contains('Bill') || label.contains('Advance') ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true, fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _karigarSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedKarigar,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Select Worker",
          prefixIcon: Icon(Icons.people, color: Colors.blueAccent),
        ),
        items: _karigars.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
        onChanged: (val) => setState(() => _selectedKarigar = val),
      ),
    );
  }

  Widget _saveAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: SizedBox(
        width: double.infinity, height: 58,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0056D2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8, shadowColor: const Color(0xFF0056D2).withOpacity(0.4)
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Confirm & Save Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
      _controllers.forEach((k, v) { if(v.text.isNotEmpty) mData[k] = v.text; });

      List<String> materials = [];
      _materialControllers.forEach((k, v) { if (v.text.isNotEmpty) materials.add("$k: ${v.text}"); });

      // Call Both Providers to save Customer AND Order
      final customerProvider = context.read<CustomerProvider>();
      final orderProvider = context.read<OrderProvider>();

      final custSaved = await customerProvider.addCustomer(
        name: widget.clientName,
        phone: widget.phone,
        orderProv: orderProvider, // Pass order provider for sync
        address: widget.address,
        gender: widget.gender,
        measurements: mData,
      );

      final orderSaved = await orderProvider.addOrder(
        clientName: widget.clientName, phone: widget.phone, garment: widget.garment,
        measurements: mData, materials: materials, totalBill: total,
        advancePayment: adv, dueAmount: due, orderDate: _orderDate,
        deliveryDate: _deliveryDate, isPinned: _isUrgent,
        karigarName: _selectedKarigar,
      );

      if (mounted) {
        if (custSaved && orderSaved) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save: ${orderProvider.errorMessage ?? 'Server error'}"), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Order Saved!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Order for ${widget.clientName} has been successfully saved to MongoDB.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 30),
            
            // Share Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       WhatsappService.shareReceipt(
                         phone: widget.phone,
                         customerName: widget.clientName,
                         garment: widget.garment,
                         shopName: "TailorBook Shop",
                         totalBill: double.tryParse(_totalPriceController.text) ?? 0.0,
                         advance: double.tryParse(_advanceController.text) ?? 0.0,
                         due: (double.tryParse(_totalPriceController.text) ?? 0.0) - (double.tryParse(_advanceController.text) ?? 0.0),
                         deliveryDate: _deliveryDate,
                       );
                    },
                    icon: const Icon(Icons.share, color: Colors.white, size: 18),
                    label: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("Awesome!", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
