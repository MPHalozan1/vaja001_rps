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
  bool _isLogin = true;
  bool _showDevMode = false;
  User? _selectedDevUser;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  void _submitAuth(DataService dataService) {
    if (_isLogin) {
      // Mock Login logic - we'll just try to find the user by name for simplicity
      final user = dataService.users.firstWhere(
        (u) => u.name.toLowerCase() == _nameController.text.toLowerCase(),
        orElse: () => User(id: '', name: '', role: UserRole.customer),
      );

      if (user.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuScreen(user: user)),
        );
      }
    } else {
      // Register logic
      if (_formKey.currentState!.validate()) {
        final newUser = dataService.selfRegisterCustomer(
          _nameController.text,
          _contactController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful. Welcome!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuScreen(user: newUser)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              dataService.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              dataService.setThemeMode(
                dataService.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RENTAL PLATFORM',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLogin ? 'SYSTEM LOGIN' : 'NEW REGISTRATION',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Username *',
                              prefixIcon: Icon(Icons.person),
                              helperText: 'Enter your account username.',
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a valid username to continue.';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Info (Email/Phone) *',
                                prefixIcon: Icon(Icons.contact_mail),
                                helperText: 'We will use this to contact you about your rentals.',
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Contact information is required for new accounts.';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: () => _submitAuth(dataService),
                              child: Text(_isLogin ? 'ENTER' : 'REGISTER'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Need an account? Register'
                                : 'Already have an account? Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () => setState(() => _showDevMode = !_showDevMode),
                  child: Text(
                    'DEV MODE',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_showDevMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Column(
                      children: [
                        DropdownButton<User>(
                          isExpanded: true,
                          value: _selectedDevUser,
                          hint: const Text('Select a dummy user'),
                          items: dataService.users.map((User user) {
                            return DropdownMenuItem<User>(
                              value: user,
                              child: Text('${user.name} (${user.role.name})'),
                            );
                          }).toList(),
                          onChanged: (User? newValue) {
                            setState(() {
                              _selectedDevUser = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          onPressed: _selectedDevUser == null
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MainMenuScreen(user: _selectedDevUser!),
                                    ),
                                  );
                                },
                          child: const Text('QUICK LOGIN'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
