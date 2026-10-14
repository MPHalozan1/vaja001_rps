import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import 'main_menu_screen.dart';

/// Prijavni in registracijski zaslon s preklopom Light/Dark teme in hitrimi testnimi računi.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController(text: 'admin@rps.local');
  final _passwordController = TextEditingController(text: 'admin');
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  UserRole _selectedRole = UserRole.customer;
  String? _errorMessage;

  final _dataService = DataService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _errorMessage = 'Please enter your full name.');
        return;
      }
      try {
        _dataService.registerUser(
          name: name,
          email: email,
          password: password,
          role: _selectedRole,
          autoSignIn: true,
        );
        _navigateToMain();
      } catch (e) {
        setState(
            () => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } else {
      final user = _dataService.signIn(email, password);
      if (user == null) {
        setState(() => _errorMessage = 'Invalid credentials. Try again.');
      } else {
        _navigateToMain();
      }
    }
  }

  /// Gladka animirana navigacija v glavni meni
  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: const MainMenuScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          // Gumb za takojšen preklop med čistim Light in Dark načinom
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: _dataService.toggleThemeMode,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 18,
              ),
              label: Text(isDark ? 'Light Mode' : 'Dark Mode'),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ListenableBuilder(
                listenable: _dataService,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.precision_manufacturing_rounded,
                              color: cs.onPrimary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RPS Rental Hub',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Equipment & Ticket Management System',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Sign In'),
                            icon: Icon(Icons.login_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('New Test User'),
                            icon: Icon(Icons.person_add_alt_1_rounded, size: 18),
                          ),
                        ],
                        selected: {_isRegisterMode},
                        onSelectionChanged: (s) {
                          setState(() {
                            _isRegisterMode = s.first;
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Column(
                          children: [
                            if (_isRegisterMode) ...[
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              onSubmitted: (_) => _handleSubmit(),
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                            ),
                            if (_isRegisterMode) ...[
                              const SizedBox(height: 14),
                              DropdownButtonFormField<UserRole>(
                                initialValue: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Account Role (Local Testing)',
                                  prefixIcon:
                                      Icon(Icons.verified_user_outlined),
                                ),
                                items: UserRole.values.map((r) {
                                  return DropdownMenuItem(
                                    value: r,
                                    child: Text(r.roleTitle),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRole = val);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: cs.onErrorContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _handleSubmit,
                        icon: Icon(
                          _isRegisterMode
                              ? Icons.person_add_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          _isRegisterMode
                              ? 'Create Account & Sign In'
                              : 'Sign In to Workspace',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: cs.outlineVariant),
                      const SizedBox(height: 12),
                      Text(
                        'INSTANT 1-CLICK DEMO ACCOUNTS (ADMIN / EMPLOYEE / CUSTOMER)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _dataService.users.map((u) {
                          final roleColor = u.isAdmin
                              ? const Color(0xFFE11D48)
                              : u.isEmployee
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF059669);
                          return ActionChip(
                            side: BorderSide(
                              color: roleColor.withValues(alpha: 0.4),
                            ),
                            avatar: CircleAvatar(
                              backgroundColor: roleColor.withValues(alpha: 0.15),
                              child: Icon(
                                u.isAdmin
                                    ? Icons.admin_panel_settings_rounded
                                    : u.isEmployee
                                        ? Icons.support_agent_rounded
                                        : Icons.person_rounded,
                                size: 14,
                                color: roleColor,
                              ),
                            ),
                            label: Text(
                              u.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            onPressed: () {
                              _dataService.quickSignIn(u);
                              _navigateToMain();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _UserRoleLabelExt on UserRole {
  String get roleTitle {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN (Full System & ROI Control)';
      case UserRole.employee:
        return 'EMPLOYEE (Ticket & Stock Operations)';
      case UserRole.customer:
        return 'CUSTOMER (Store & Reservations)';
    }
  }
}