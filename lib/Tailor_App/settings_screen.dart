import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            subtitle: "Manage shop name, address, and logo",
            color: Colors.blueAccent,
            onTap: () {},
          ),
          _settingsItem(
            context: context,
            icon: Icons.straighten,
            title: t('measurements'),
            subtitle: "Set units to Inches or Centimeters",
            color: Colors.greenAccent,
            onTap: () {},
          ),
          _settingsItem(
            context: context,
            icon: Icons.notifications_active_outlined,
            title: t('notifications'),
            subtitle: "Manage delivery and payment alerts",
            color: Colors.orangeAccent,
            onTap: () {},
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
            subtitle: "Change password and account security",
            color: Colors.redAccent,
            onTap: () {},
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
