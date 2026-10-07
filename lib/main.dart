import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/sign_in_screen.dart';
import 'screens/customer_dashboard_screen.dart';
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
    return MaterialApp(
      title: 'Item Borrowing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
        // Note: '/catalog' needs currentUser, so we remove it from static routes and use push(MaterialPageRoute) in MainMenuScreen
        '/customer_dashboard': (context) => const CustomerDashboardScreen(),
      },
    );
  }
}
