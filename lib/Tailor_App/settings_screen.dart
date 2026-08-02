import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_provider.dart';
import 'app_translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('settings'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsItem(
            context: context,
            icon: Icons.storefront,
            title: t('business_profile'),
            subtitle: t('business_details'),
            color: Colors.blueAccent,
            onTap: () => _showBusinessProfileDialog(context, t),
          ),
          _settingsItem(
            context: context,
            icon: Icons.straighten,
            title: t('measurements'),
            subtitle: t('unit_desc'),
            color: Colors.greenAccent,
            onTap: () => _showMeasurementUnitDialog(context, settings, t),
          ),
          _settingsItem(
            context: context,
            icon: Icons.notifications_active_outlined,
            title: t('notifications'),
            subtitle: t('notif_desc'),
            color: Colors.orangeAccent,
            onTap: () => _showNotificationSettingsDialog(context, settings, t),
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
            subtitle: "Change password, update email, and logout",
            color: Colors.redAccent,
            onTap: () => _showAccountSecurityDialog(context, t),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Tailor Book v1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showBusinessProfileDialog(BuildContext context, String Function(String) t) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};

    final shopNameController = TextEditingController(text: data['shopName'] ?? '');
    final contactController = TextEditingController(text: data['shopContact'] ?? '');
    final addressController = TextEditingController(text: data['shopAddress'] ?? '');
    final logoController = TextEditingController(text: data['shopLogo'] ?? '');

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('business_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: InputDecoration(labelText: t('shop_name'), prefixIcon: const Icon(Icons.store)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: t('shop_contact'), prefixIcon: const Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: t('shop_address'), prefixIcon: const Icon(Icons.location_on)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: logoController,
                decoration: InputDecoration(labelText: t('shop_logo'), prefixIcon: const Icon(Icons.link), hintText: "https://..."),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'shopName': shopNameController.text.trim(),
                'shopContact': contactController.text.trim(),
                'shopAddress': addressController.text.trim(),
                'shopLogo': logoController.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('success')), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white),
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context, SettingsProvider settings, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t('notifications'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(t('delivery_reminder')),
                secondary: const Icon(Icons.alarm, color: Colors.orangeAccent),
                value: settings.deliveryReminder,
                onChanged: (val) {
                  settings.toggleDeliveryReminder(val);
                },
              ),
              SwitchListTile(
                title: Text(t('payment_reminder')),
                secondary: const Icon(Icons.payment, color: Colors.greenAccent),
                value: settings.paymentReminder,
                onChanged: (val) {
                  settings.togglePaymentReminder(val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ],
        ),
      ),
    );
  }

  void _showMeasurementUnitDialog(BuildContext context, SettingsProvider settings, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('select_unit'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(t('inches')),
              value: 'inches',
              groupValue: settings.measurementUnit,
              onChanged: (val) {
                if (val != null) settings.setMeasurementUnit(val);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: Text(t('cm')),
              value: 'cm',
              groupValue: settings.measurementUnit,
              onChanged: (val) {
                if (val != null) settings.setMeasurementUnit(val);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

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
              leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
              title: Text(t('change_password')),
              onTap: () {
                Navigator.pop(ctx);
                _showChangePasswordDialog(context, t);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.blueAccent),
              title: Text(t('update_email')),
              onTap: () {
                Navigator.pop(ctx);
                _showUpdateEmailDialog(context, t);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
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

  void _showChangePasswordDialog(BuildContext context, String Function(String) t) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('change_password')),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: InputDecoration(hintText: t('new_password')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.updatePassword(passController.text);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('password_updated')), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('reauth_needed')), backgroundColor: Colors.red));
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context, String Function(String) t) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_email')),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(hintText: t('new_email')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.updateEmail(emailController.text);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('email_updated')), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('reauth_needed')), backgroundColor: Colors.red));
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
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
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context); // Go back from settings to trigger main.dart listener
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(t('logout_title')),
          ),
        ],
      ),
    );
  }

  void _showThemeLanguageDialog(BuildContext context, SettingsProvider settings, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t('theme'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle
              SwitchListTile(
                title: Text(t('dark_mode')),
                secondary: Icon(Icons.dark_mode, color: Colors.purple.shade300),
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  settings.toggleTheme(val);
                },
              ),
              const Divider(),
              // Language Selection
              ListTile(
                title: Text(t('language')),
                leading: const Icon(Icons.language, color: Colors.blue),
                subtitle: Text(_getLangName(settings.locale.languageCode)),
                onTap: () {
                  _showLanguagePicker(context, settings, t);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings, String Function(String) t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t('select_lang'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _langOption(context, settings, "English", "en"),
            _langOption(context, settings, "اردو (Urdu)", "ur"),
            _langOption(context, settings, "हिंदी (Hindi)", "hi"),
            _langOption(context, settings, "پښتو (Pashto)", "ps"),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, SettingsProvider settings, String name, String code) {
    bool isSelected = settings.locale.languageCode == code;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      onTap: () {
        settings.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  String _getLangName(String code) {
    switch (code) {
      case 'ur': return "اردو (Urdu)";
      case 'hi': return "हिंदी (Hindi)";
      case 'ps': return "پښتو (Pashto)";
      default: return "English";
    }
  }

  Widget _settingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
