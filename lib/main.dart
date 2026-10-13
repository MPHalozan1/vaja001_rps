import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/sign_in_screen.dart';
import 'services/data_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    // Light Theme Definition (SaaS / E-commerce style)
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.light,
        primary: const Color(0xFF0F172A), // Slate 900
        secondary: const Color(0xFF3B82F6), // Blue 500
        surface: const Color(0xFFF8FAFC), // Slate 50
        surfaceContainerHighest: const Color(0xFFE2E8F0),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );

    // Dark Theme Definition
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
        primary: const Color(0xFF60A5FA), // Blue 400
        secondary: const Color(0xFF93C5FD), // Blue 300
        surface: const Color(0xFF1E1E1E),
        surfaceContainerHighest: const Color(0xFF2D2D2D),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D2D2D), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );

    return MaterialApp(
      title: 'Premium Rentals',
      themeMode: dataService.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
      },
    );
  }
}
