import 'package:flutter/material.dart';
import 'package:flutter_application_visual1/homescram.dart';

void main() {
  runApp(const AgendaApp());
}

class AgendaApp extends StatefulWidget {
  const AgendaApp({super.key});

  @override
  State<AgendaApp> createState() => _AgendaAppState();
}

class _AgendaAppState extends State<AgendaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toogleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }
  @override
Widget build(BuildContext context) {
  final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F0EA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7209B7),
      secondary: Color(0xFF3F37C9),
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0B14),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD042FF),
      secondary: Color(0xFF00F5D4),
      surface: Color(0xFF181325),
      onSurface: Colors.white,
    ),
  );

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Agenda Prática',
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: _themeMode,
    home: HomeScream(
      onToogleTheme: _toogleTheme,
      isDarkMode: _themeMode == ThemeMode.dark,
    ),
  );
}

}

