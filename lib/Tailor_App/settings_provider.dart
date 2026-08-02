import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  bool _deliveryReminder = true;
  bool _paymentReminder = true;
  String _measurementUnit = 'inches'; // 'inches' or 'cm'

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get deliveryReminder => _deliveryReminder;
  bool get paymentReminder => _paymentReminder;
  String get measurementUnit => _measurementUnit;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Load Locale
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);

    // Load Notifications
    _deliveryReminder = prefs.getBool('deliveryReminder') ?? true;
    _paymentReminder = prefs.getBool('paymentReminder') ?? true;

    // Load Measurement Unit
    _measurementUnit = prefs.getString('measurementUnit') ?? 'inches';

    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<void> toggleDeliveryReminder(bool val) async {
    _deliveryReminder = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deliveryReminder', val);
  }

  Future<void> togglePaymentReminder(bool val) async {
    _paymentReminder = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paymentReminder', val);
  }

  Future<void> setMeasurementUnit(String unit) async {
    _measurementUnit = unit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('measurementUnit', unit);
  }
}
