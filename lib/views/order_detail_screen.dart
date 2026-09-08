import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_provider.dart';
import '../core/date_formatter.dart';
import '../services/whatsapp_service.dart';
import '../services/pdf_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final List<String> _karigars = ["Master (Self)", "Ahmad (Tailor)", "Bilal (Tailor)", "Hamza (Specialist)", "Zeeshan (Master)"];

  Color get _statusColor {
    switch (widget.order['status']) {
      case 'complete':
        return const Color(0xFF00C853);
      case 'delivered':
        return const Color(0xFF2979FF);
      default:
        return const Color(0xFFFF8C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurements = widget.order['measurements'] as Map<String, dynamic>? ?? {};
    final materials = widget.order['materials'] as List<dynamic>? ?? [];
    final orderDate = widget.order['orderDate'];
    final deliveryDate = widget.order['deliveryDate'];

    double totalBill = (widget.order['totalBill'] ?? 0).toDouble();
    double advance = (widget.order['advancePayment'] ?? 0).toDouble();
    double due = (widget.order['dueAmount'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.order['clientName'] ?? 'Order Details',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => _generatePdf(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Order Info Card
            _buildInfoCard(orderDate, deliveryDate),
            const SizedBox(height: 16),

            // 2. Payment Card (Due Payment)
            _buildPaymentCard(totalBill, advance, due),
            const SizedBox(height: 16),

            // 3. Sharing & Print Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToWhatsapp,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text("Print Parchi", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Materials Section
            if (materials.isNotEmpty)
              _buildMaterialsSection(materials),
            const SizedBox(height: 16),

            // 5. Measurements Section
            if (measurements.isNotEmpty)
              _buildSection("Measurements", Icons.straighten, const Color(0xFF6C63FF), measurements, "inch"),
            const SizedBox(height: 24),

            // Action Buttons
            if (due > 0)
              _actionBtn("Collect Balance (Rs. $due)", Colors.blueGrey, Icons.payments, _collectDuePayment),
            
            const SizedBox(height: 12),

            _actionBtn("Assign / Change Worker", Colors.blueAccent, Icons.person_add_alt, _showWorkerSelection),

            const SizedBox(height: 12),

            if (widget.order['status'] == 'pending')
              _actionBtn("Mark as Complete", const Color(0xFF00C853), Icons.check_circle_outline, () => _updateStatus('complete')),
            
            if (widget.order['status'] == 'complete')
              _actionBtn("Mark as Delivered", const Color(0xFF2979FF), Icons.local_shipping, () => _updateStatus('delivered')),
            
            const SizedBox(height: 20),

            _actionBtn("Delete Order Record", Colors.redAccent.withOpacity(0.8), Icons.delete_forever, _deleteOrder),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _shareToWhatsapp() {
    WhatsappService.shareReceipt(
      phone: widget.order['phone'] ?? '',
      customerName: widget.order['clientName'] ?? '',
      garment: widget.order['garment'] ?? '',
      shopName: "TailorBook Shop", // This should come from settings
      totalBill: (widget.order['totalBill'] ?? 0).toDouble(),
      advance: (widget.order['advancePayment'] ?? 0).toDouble(),
      due: (widget.order['dueAmount'] ?? 0).toDouble(),
      deliveryDate: widget.order['deliveryDate'],
    );
  }

  void _generatePdf() {
    PdfService.generateAndPrintReceipt(
      order: widget.order,
      shopName: "TailorBook Shop",
      shopAddress: "Main Market, Street 7",
      shopPhone: "0300-1234567",
    );
  }

  void _deleteOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Order?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this order? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<OrderProvider>().deleteOrder(widget.orderId);
              if (mounted && success) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Deleted"), backgroundColor: Colors.redAccent));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic orderDate, dynamic deliveryDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.person, const Color(0xFF0056D2)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.order['clientName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.order['garment'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              _statusChip(widget.order['status'] ?? 'pending'),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.phone_outlined, "Phone", widget.order['phone'] ?? '', const Color(0xFFFF6B6B)),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on_outlined, "Address", widget.order['address'] ?? '', const Color(0xFF4ECDC4)),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today, "Order Date", DateFormatter.format(orderDate), const Color(0xFFFF8C00)),
          const SizedBox(height: 12),
          _infoRow(Icons.event, "Delivery Date", DateFormatter.format(deliveryDate), const Color(0xFF00C853)),
          if (widget.order['karigarName'] != null && widget.order['karigarName'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.engineering_outlined, "Assigned To", widget.order['karigarName'], Colors.blueGrey),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(double total, double adv, double due) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.account_balance_wallet, Colors.green),
              const SizedBox(width: 12),
              const Text("Payment Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          _payRow("Total Bill", "Rs. ${total.toInt()}", Colors.black87),
          _payRow("Advance Paid", "Rs. ${adv.toInt()}", Colors.blue),
          const Divider(),
          _payRow("Remaining Due", "Rs. ${due.toInt()}", due > 0 ? Colors.red : Colors.green, isBold: true),
        ],
      ),
    );
  }

  Widget _payRow(String label, String val, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  void _collectDuePayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Collect Balance"),
        content: const Text("Receive remaining payment and clear dues?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                final total = (widget.order['totalBill'] ?? 0).toDouble();
                final success = await context.read<OrderProvider>().collectPayment(widget.orderId, total);
                if (mounted && success) {
                  Navigator.pop(ctx);
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Updated Successfully!"), backgroundColor: Colors.green));
                }
              } catch (e) {
                print(e);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Paid"),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String status) async {
    final success = await context.read<OrderProvider>().updateStatus(widget.orderId, status);
    if (mounted && success) Navigator.pop(context);
  }

  void _showWorkerSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Karigar / Worker", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ..._karigars.map((k) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
              title: Text(k),
              onTap: () async {
                final success = await context.read<OrderProvider>().updateKarigar(widget.orderId, k);
                if (mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    Navigator.pop(context); // Go back to refresh list
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Assigned to $k"), backgroundColor: Colors.green));
                  }
                }
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor.withOpacity(0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDuePaymentSection(double due) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.account_balance_wallet, Colors.redAccent),
              const SizedBox(width: 12),
              const Text("Due Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(due > 0 ? "Baqaya (Remaining)" : "Payment Clear", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              Text("Rs. ${due.toInt()}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: due > 0 ? Colors.red : Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(List<dynamic> materials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.inventory_2_outlined, Colors.blue),
              const SizedBox(width: 12),
              const Text("Materials Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...materials.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text("- $m", style: const TextStyle(fontWeight: FontWeight.w500)),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color baseColor, Map<String, dynamic> data, String suffix) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: baseColor.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon, baseColor),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.where((e) => e.value.toString().isNotEmpty).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: TextStyle(color: Colors.grey.shade700)),
                Text(suffix == "inch" ? "${e.value} \"" : "${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
