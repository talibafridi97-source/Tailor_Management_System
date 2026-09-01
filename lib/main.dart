import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'services/auth_service.dart';
import 'views/home_screen.dart';
import 'views/tailor_book.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsController(),
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
        Locale('hi'),
        Locale('ps'),
      ],
      // FutureBuilder async token fetch hone ka wait karega
      home: FutureBuilder<String?>(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          // Jab tak storage se token read ho raha hai:
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Read hone ke baad token verify karein:
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return const HomeScreen();
          }

          // Token na hone par TailorBookScreen dikhain:
          return const TailorBookScreen();
        },
      ),
    );
  }
}