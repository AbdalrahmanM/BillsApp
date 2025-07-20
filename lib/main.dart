import 'package:flutter/material.dart';
import 'screens/theme_controller.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

final themeController = ThemeController();

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
          home: LoginScreen(),
        );
      },
    );
  }
}
