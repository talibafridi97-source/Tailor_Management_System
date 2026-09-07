import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  static Future<void> shareReceipt({
    required String phone,
    required String customerName,
    required String garment,
    required String shopName,
    required double totalBill,
    required double advance,
    required double due,
    required dynamic deliveryDate,
  }) async {
    // Phone number cleaning (remove spaces/dashes)
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Add Pakistan country code if it starts with 0
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92' + cleanPhone.substring(1);
    } else if (!cleanPhone.startsWith('92') && cleanPhone.length == 10) {
      cleanPhone = '92' + cleanPhone;
    }

    final String statusMsg = due <= 0 ? "Taiyar (Ready)" : "Taiyar hai, Baqaya ada karein";
    
    final String message = 
        "📢 *Tailor Book: Order Update*\n\n"
        "Assalam-o-Alaikum *$customerName*,\n"
        "Aapka *$garment* ab *$statusMsg* hai.\n\n"
        "--------------------------\n"
        "💰 *Hisab Kitab:*\n"
        "Total Bill: Rs. ${totalBill.toInt()}\n"
        "Advance: Rs. ${advance.toInt()}\n"
        "*Baqaya (Due): Rs. ${due.toInt()}*\n\n"
        "📍 *Shop:* $shopName\n"
        "--------------------------\n"
        "Aap kisi bhi waqt tashreef la kar apna order le sakte hain.";

    // URL to open WhatsApp app directly
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      // Trying to launch without strict canLaunchUrl check first for reliability
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback for some devices
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print("WhatsApp Error: $e");
    }
  }
}
