import 'package:flutter/foundation.dart';
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
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('92') && cleanPhone.length == 10) {
      cleanPhone = '92$cleanPhone';
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

    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("WhatsApp Error: $e");
    }
  }

  static Future<void> sendDeliveryReminder({
    required String phone,
    required String customerName,
    required String garment,
    required String shopName,
    required dynamic deliveryDate,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('92') && cleanPhone.length == 10) {
      cleanPhone = '92$cleanPhone';
    }

    final String message = 
        "📦 *TailorBook - Delivery Reminder*\n\n"
        "Assalam-o-Alaikum *$customerName*,\n"
        "Aapka order (*$garment*) taiyar hai aur delivery ki date *$deliveryDate* hai.\n\n"
        "📍 *Shop:* $shopName\n"
        "Barah-e-karam apna order receive karne ke liye tashreef layein. Shukriya!";

    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("WhatsApp Delivery Reminder Error: $e");
    }
  }

  static Future<void> sendPaymentBalanceReminder({
    required String phone,
    required String customerName,
    required String garment,
    required double totalBill,
    required double advance,
    required double due,
    required String shopName,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('92') && cleanPhone.length == 10) {
      cleanPhone = '92$cleanPhone';
    }

    final String message = 
        "💳 *TailorBook - Payment Balance Reminder*\n\n"
        "Assalam-o-Alaikum *$customerName*,\n"
        "Aapke order (*$garment*) ka baqaya balance rehta hai.\n\n"
        "💰 *Hisab Kitab:*\n"
        "Total Bill: Rs. ${totalBill.toInt()}\n"
        "Advance Paid: Rs. ${advance.toInt()}\n"
        "*Remaining Due (Baqaya): Rs. ${due.toInt()}*\n\n"
        "📍 *Shop:* $shopName\n"
        "Barah-e-karam baqaya raqam ada farmayein. Shukriya!";

    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("WhatsApp Payment Reminder Error: $e");
    }
  }
}
