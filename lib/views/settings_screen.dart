import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../core/app_translations.dart';
import '../services/auth_service.dart';
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
          const SizedBox(height: 20),
          const Center(child: Text("Tailor Book v1.1.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  void _showBusinessProfileDialog(BuildContext context, SettingsController settings, String Function(String) t) {
    final shopNameController = TextEditingController(text: settings.shopName);
    final contactController = TextEditingController(text: settings.shopContact);
    final addressController = TextEditingController(text: settings.shopAddress);
    final logoController = TextEditingController(text: settings.shopLogo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('business_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: shopNameController, decoration: InputDecoration(labelText: t('shop_name'), prefixIcon: const Icon(Icons.store))),
              const SizedBox(height: 10),
              TextField(controller: contactController, decoration: InputDecoration(labelText: t('shop_contact'), prefixIcon: const Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              TextField(controller: addressController, decoration: InputDecoration(labelText: t('shop_address'), prefixIcon: const Icon(Icons.location_on))),
              const SizedBox(height: 10),
              TextField(controller: logoController, decoration: InputDecoration(labelText: "Logo URL", prefixIcon: const Icon(Icons.link))),
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
                logo: logoController.text,
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
            ListTile(
              title: Text(t('language')),
              subtitle: Text(settings.locale.languageCode == 'en' ? "English" : "اردو"),
              onTap: () {
                settings.setLanguage(settings.locale.languageCode == 'en' ? 'ur' : 'en');
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
}
