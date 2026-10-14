import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'controllers/order_provider.dart';
import 'controllers/customer_provider.dart';
import 'controllers/inventory_provider.dart';
import 'controllers/expense_provider.dart';
import 'services/auth_service.dart';
import 'views/home_screen.dart';
import 'views/tailor_book.dart';
import 'views/customer_order_screen.dart';
import 'core/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showLocalNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title ?? 'Notification',
    body ?? '',
    platformChannelSpecifics,
  );
}

void showInAppNotificationDialog(String title, String body) {
  final context = _navigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1A1A2E),
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.amber, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        ],
      ),
      content: Text(body, style: const TextStyle(color: Colors.white70, fontSize: 15)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(ctx),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

Future<void> _syncFcmToken(String? fcmToken) async {
  if (fcmToken == null || fcmToken.isEmpty) return;
  try {
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/auth/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      print("FCM Token Sync Status: ${response.statusCode}");
    }
  } catch (e) {
    print("FCM Token Sync Error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      await initLocalNotifications();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      final fcmToken = await messaging.getToken();
      print("FCM DEVICE TOKEN: $fcmToken");
      await _syncFcmToken(fcmToken);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Foreground Notification received: ${message.notification?.title}');
        if (message.notification != null) {
          // 1. Play sound & trigger notification sound/tray
          await showLocalNotification(message.notification!.title, message.notification!.body);

          // 2. Show gorgeous alert dialog popup right in the center of the screen
          await Future.delayed(const Duration(milliseconds: 200));
          showInAppNotificationDialog(
            message.notification!.title ?? 'New Order Created!',
            message.notification!.body ?? '',
          );
        }
      });
    } catch (e) {
      print("Firebase init error: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Tailor Book App',
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      locale: settings.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('ar'),
        Locale('hi'),
        Locale('ps'),
      ],
      home: kIsWeb
          ? const CustomerOrderScreen()
          : FutureBuilder<String?>(
              future: AuthService.getToken(),
              builder: (context, snapshot) {
                1; // Dummy statement to preserve structure
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return const HomeScreen();
          }

          return const TailorBookScreen();
        },
      ),
    );
  }
}
