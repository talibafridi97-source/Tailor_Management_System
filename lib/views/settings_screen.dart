import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../core/app_translations.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';
import 'tailor_book.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final locale = settings.locale.languageCode;

    String t(String key) => AppTranslations.getText(key, locale);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF5F7FA) : Colors.black87,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(t('settings'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsItem(
            context: context,
            icon: Icons.storefront,
            title: t('business_profile'),
            subtitle: settings.shopName,
            color: Colors.blueAccent,
            onTap: () => _showBusinessProfileDialog(context, settings, t),
          ),
          _settingsItem(
            context: context,
            icon: Icons.palette_outlined,
            title: t('theme'),
            subtitle: t('theme_sub'),
            color: Colors.purpleAccent,
            onTap: () => _showThemeLanguageDialog(context, settings, t),
          ),
          _settingsItem(
            context: context,
            icon: Icons.security,
            title: t('account'),
            subtitle: "Logout and Security",
            color: Colors.redAccent,
            onTap: () => _showAccountSecurityDialog(context, t),
          ),
          _settingsItem(
            context: context,
            icon: Icons.dns,
            title: t('server_config'),
            subtitle: t('server_config_sub'),
            color: Colors.teal,
            onTap: () => _showServerConfigDialog(context, t),
          ),
          const SizedBox(height: 20),
          const Center(child: Text("Tailor Book v1.1.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, Function(String) onImagePicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Take a Photo (Camera)"),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                  maxWidth: 300,
                  maxHeight: 300,
                );
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  final base64String = base64Encode(bytes);
                  onImagePicked(base64String);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                  maxWidth: 300,
                  maxHeight: 300,
                );
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  final base64String = base64Encode(bytes);
                  onImagePicked(base64String);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessProfileDialog(BuildContext context, SettingsController settings, String Function(String) t) {
    final shopNameController = TextEditingController(text: settings.shopName);
    final contactController = TextEditingController(text: settings.shopContact);
    final addressController = TextEditingController(text: settings.shopAddress);
    String currentLogo = settings.shopLogo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t('business_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _showImageSourceActionSheet(context, (base64Image) {
                      setStateDialog(() {
                        currentLogo = base64Image;
                      });
                    });
                  },
                  child: Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: currentLogo.isNotEmpty
                              ? (currentLogo.startsWith('http')
                                  ? NetworkImage(currentLogo) as ImageProvider
                                  : MemoryImage(base64Decode(currentLogo)))
                              : null,
                          child: currentLogo.isEmpty
                              ? const Icon(Icons.store, size: 40, color: Colors.grey)
                              : null,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(controller: shopNameController, decoration: InputDecoration(labelText: t('shop_name'), prefixIcon: const Icon(Icons.store))),
                const SizedBox(height: 10),
                TextField(controller: contactController, decoration: InputDecoration(labelText: t('shop_contact'), prefixIcon: const Icon(Icons.phone)), keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(controller: addressController, decoration: InputDecoration(labelText: t('shop_address'), prefixIcon: const Icon(Icons.location_on))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
            ElevatedButton(
              onPressed: () async {
                final success = await settings.updateBusinessProfile(
                  name: shopNameController.text,
                  contact: contactController.text,
                  address: addressController.text,
                  logo: currentLogo,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? "Profile Updated!" : "Update Failed"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
              child: Text(t('save')),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Baqi methods same rahenge)
  void _showAccountSecurityDialog(BuildContext context, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('account'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(t('logout_title')),
              onTap: () {
                Navigator.pop(ctx);
                _showLogoutConfirm(context, t);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('logout_title')),
        content: Text(t('logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              await AuthService.removeToken();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TailorBookScreen()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t('logout_title')),
          ),
        ],
      ),
    );
  }

  void _showThemeLanguageDialog(BuildContext context, SettingsController settings, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('theme'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(t('dark_mode')),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (val) => settings.toggleTheme(val),
            ),
            const Divider(),
            ListTile(
              title: Text(t('language')),
              subtitle: Text(
                settings.locale.languageCode == 'en'
                    ? "English"
                    : settings.locale.languageCode == 'ur'
                        ? "اردو (Urdu)"
                        : "العربية (Arabic)",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _showLanguageSelectorDialog(context, settings, t);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectorDialog(BuildContext context, SettingsController settings, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('select_lang'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text("English"),
              value: 'en',
              groupValue: settings.locale.languageCode,
              onChanged: (val) {
                if (val != null) settings.setLanguage(val);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text("اردو (Urdu)"),
              value: 'ur',
              groupValue: settings.locale.languageCode,
              onChanged: (val) {
                if (val != null) settings.setLanguage(val);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text("العربية (Arabic)"),
              value: 'ar',
              groupValue: settings.locale.languageCode,
              onChanged: (val) {
                if (val != null) settings.setLanguage(val);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  void _showServerConfigDialog(BuildContext context, String Function(String) t) {
    final ipController = TextEditingController(text: ApiConfig.ip);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('server_config'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Format: 192.168.1.10 (No http:// or ports needed here unless required)", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: t('server_ip'),
                prefixIcon: const Icon(Icons.computer),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              String newIp = ipController.text.trim();
              if (newIp.isNotEmpty) {
                await ApiConfig.setIp(newIp);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Server IP Updated to: \$newIp"),
                    backgroundColor: Colors.green,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }
}
