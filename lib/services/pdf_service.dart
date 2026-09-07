import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/date_formatter.dart';

class PdfService {
  static Future<void> generateAndPrintReceipt({
    required Map<String, dynamic> order,
    required String shopName,
    required String shopAddress,
    required String shopPhone,
  }) async {
    final pdf = pw.Document();

    final measurements = order['measurements'] as Map<String, dynamic>? ?? {};
    final materials = order['materials'] as List<dynamic>? ?? [];

    // Faster generation by using simple shapes and standard fonts
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(shopName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Contact: $shopPhone", style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(thickness: 1),
                      ],
                    ),
                  ),
                ),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Customer: ${order['clientName']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text("Date: ${DateFormatter.format(order['orderDate'])}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text("Suit Type: ${order['garment']}", style: const pw.TextStyle(fontSize: 11)),
                pw.Text("Delivery: ${DateFormatter.format(order['deliveryDate'])}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red, fontSize: 11)),
                
                pw.SizedBox(height: 10),
                pw.Text("MEASUREMENTS (Inch)", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 0.5),
                
                pw.Wrap(
                  spacing: 15,
                  runSpacing: 5,
                  children: measurements.entries.map((e) => 
                    pw.Container(
                      width: 80,
                      child: pw.Text("${e.key}: ${e.value}", style: const pw.TextStyle(fontSize: 9))
                    )
                  ).toList(),
                ),

                if (materials.isNotEmpty) ...[
                  pw.SizedBox(height: 15),
                  pw.Text("MATERIALS PROVIDED", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(thickness: 0.5),
                  ...materials.map((m) => pw.Text("• $m", style: const pw.TextStyle(fontSize: 9))),
                ],

                pw.Spacer(),
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL BILL:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Rs. ${order['totalBill']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("ADVANCE:"),
                    pw.Text("Rs. ${order['advancePayment']}"),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("REMAINING DUE (Baqaya):", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                    pw.Text("Rs. ${order['dueAmount']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text("System Generated Receipt by TailorBook", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey))),
              ],
            ),
          );
        },
      ),
    );

    // Layout the PDF (Trigger system dialog immediately)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Receipt_${order['clientName']}",
    );
  }
}
