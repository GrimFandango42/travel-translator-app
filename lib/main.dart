import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TravelTranslatorApp());
}

class TravelTranslatorApp extends StatelessWidget {
  const TravelTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}