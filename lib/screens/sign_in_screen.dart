import 'package:flutter/material.dart';
import '../models/user.dart';
import 'main_menu_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login as:'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final adminUser = User(id: '1', name: 'Alice Admin', role: UserRole.admin);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMenuScreen(user: adminUser)));
              },
              child: const Text('Admin'),
            ),
            ElevatedButton(
              onPressed: () {
                final employeeUser = User(id: '2', name: 'Bob Employee', role: UserRole.employee);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMenuScreen(user: employeeUser)));
              },
              child: const Text('Employee'),
            ),
            ElevatedButton(
              onPressed: () {
                final customerUser = User(id: '3', name: 'Charlie Customer', role: UserRole.customer);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMenuScreen(user: customerUser)));
              },
              child: const Text('Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
