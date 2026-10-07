import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/item_catalog_screen.dart';
import 'screens/borrow_form_screen.dart';
import 'screens/customer_dashboard_screen.dart';
import 'screens/management_dashboard_screen.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Borrowing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
        '/catalog': (context) => const ItemCatalogScreen(),
        '/borrow': (context) => const BorrowFormScreen(),
        '/customer_dashboard': (context) => const CustomerDashboardScreen(),
        '/management_dashboard': (context) => const ManagementDashboardScreen(),
      },
      // Note: MainMenuScreen requires a user parameter, so it shouldn't be a simple route without arguments.
      // Or we can pass the dummy user for testing purposes when routing dynamically.
    );
  }
}
