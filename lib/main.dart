import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер Европочты',
      debugShowCheckedModeBanner: false,
        theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Акцентный цвет
          brightness: Brightness.dark, // Тёмная тема, если нужно
        ),
      ),
      home: const MainScreen(),
    );
  }
}
