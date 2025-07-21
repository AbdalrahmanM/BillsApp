import 'package:bills_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/theme_controller.dart';
import 'screens/login_screen.dart';

final themeController = ThemeController();
final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

//import 'screens/home_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.brown,
                scaffoldBackgroundColor: Color(0xFFFAEBD7),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.brown,
                scaffoldBackgroundColor: Color(0xFF232323),
              ),
              themeMode: mode,
              home: LoginScreen(localeNotifier: localeNotifier),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('ar'), // Arabic
              ],
              locale:
                  locale, // <-- This line makes the app rebuild with the new locale
            );
          },
        );
      },
    );
  }
}
