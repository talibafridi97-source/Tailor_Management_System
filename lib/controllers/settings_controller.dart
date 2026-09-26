import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../core/api_config.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  String _measurementUnit = 'inches';
  bool _deliveryReminder = true;
  bool _paymentReminder = true;

  // Business Details
  String shopName = 'Tailor Book';
  String shopContact = '';
  String shopAddress = '';
  String shopLogo = '';

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get measurementUnit => _measurementUnit;
  bool get deliveryReminder => _deliveryReminder;
  bool get paymentReminder => _paymentReminder;

  SettingsController() {
    _loadSettings();
    fetchUserProfile(); // App khulte hi profile load karein
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(prefs.getString('languageCode') ?? 'en');
    shopName = prefs.getString('shopName') ?? 'Tailor Book';
    notifyListeners();
  }

  // Backend se User Profile mangwana
  Future<void> fetchUserProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiConfig.profile), // Profile endpoint
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        shopName = data['shopName'] ?? 'Tailor Book';
        shopContact = data['shopContact'] ?? '';
        shopAddress = data['shopAddress'] ?? '';
        shopLogo = data['shopLogo'] ?? '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shopName', shopName);
        notifyListeners();
      }
    } catch (e) {
      print("Profile Fetch Error: $e");
    }
  }

  // Profile Update karna
  Future<bool> updateBusinessProfile({
    required String name,
    required String contact,
    required String address,
    required String logo,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shopName': name,
          'shopContact': contact,
          'shopAddress': address,
          'shopLogo': logo,
        }),
      );

      print("Update Profile Status: ${response.statusCode}");
      print("Update Profile Response: ${response.body}");

      if (response.statusCode == 200) {
        shopName = name;
        shopContact = contact;
        shopAddress = address;
        shopLogo = logo;
        
        print("Profile updated successfully locally.");
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shopName', shopName);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Update Profile Exception: $e");
      return false;
    }
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  void setLanguage(String code) async {
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    notifyListeners();
  }

  void setMeasurementUnit(String unit) {
    _measurementUnit = unit;
    notifyListeners();
  }

  void toggleDeliveryReminder(bool val) {
    _deliveryReminder = val;
    notifyListeners();
  }

  void togglePaymentReminder(bool val) {
    _paymentReminder = val;
    notifyListeners();
  }
}
