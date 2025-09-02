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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FORGE',
      theme: ThemeData(
        fontFamily: 'Noto',
        //fontFamily: 'RobotoCondensed',
        primaryColor: Color(0xFFFCA311),
        scaffoldBackgroundColor: Color.fromARGB(255, 19, 19, 19), // The background color of the scaffold
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white54),
          bodyMedium: TextStyle(color: Colors.white54),
          bodySmall: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.black87),
          titleSmall: TextStyle(color: Colors.black54),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "FORGE",),
    );
  }
}
