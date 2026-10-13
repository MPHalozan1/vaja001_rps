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
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0D11), Color(0xFF15151A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Premium Rentals',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isLogin ? 'Welcome Back' : 'Create an Account',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username *',
                                  helperText: 'Enter your full display name.',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? 'Username is mandatory.' : null,
                              ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _contactController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contact Info *',
                                    helperText: 'Email or phone number.',
                                    prefixIcon: Icon(Icons.contact_mail),
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty ? 'Contact information is mandatory.' : null,
                                ),
                              ],
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  onPressed: () => _submitAuth(dataService),
                                  child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    // Intentionally not clearing controllers to retain data
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Need an account? Sign Up'
                                    : 'Already have an account? Log In'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () => setState(() => _showDevMode = !_showDevMode),
                    child: Text(
                      '// DEV MODE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (_showDevMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.secondary),
                        borderRadius: BorderRadius.circular(8),
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
                              foregroundColor: Theme.of(context).colorScheme.secondary,
                              side: BorderSide(color: Theme.of(context).colorScheme.secondary),
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
        ],
      ),
    );
  }
}
