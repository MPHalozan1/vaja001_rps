import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import 'main_menu_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  User? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Borrowing System'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text('Please select a user to log in:'),
                  const SizedBox(height: 16),
                  DropdownButton<User>(
                    isExpanded: true,
                    value: _selectedUser,
                    hint: const Text('Select a user'),
                    items: dataService.users.map((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text('${user.name} (${user.role.name})'),
                      );
                    }).toList(),
                    onChanged: (User? newValue) {
                      setState(() {
                        _selectedUser = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _selectedUser == null
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainMenuScreen(user: _selectedUser!),
                              ),
                            );
                          },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
