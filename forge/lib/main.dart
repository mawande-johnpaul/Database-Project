import 'package:flutter/material.dart';
import 'package:forge/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark().copyWith(
      primaryColor: const Color(0xFFFCA311),
      scaffoldBackgroundColor: const Color.fromARGB(255, 19, 19, 19),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFCA311),
        secondary: Color(0xFF14213D),
        surface: Color.fromARGB(255, 30, 30, 30),
        onSurface: Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        foregroundColor: Colors.white70,
      ),
      cardTheme: CardThemeData(
        color: const Color.fromARGB(255, 40, 40, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white54),
        bodyMedium: TextStyle(color: Colors.white54),
        bodySmall: TextStyle(color: Colors.white38),
        titleLarge: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white70),
        titleSmall: TextStyle(color: Colors.white70),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FORGE',
      theme: ThemeData(
        fontFamily: 'Noto',
        primaryColor: const Color(0xFF14213D),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF14213D),
          secondary: Color(0xFFFCA311),
        ),
        useMaterial3: true,
      ),
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Force dark theme
      home: const MyHomePage(title: "FORGE"),
    );
  }
}
