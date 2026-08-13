import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(
    text: 'user@healthcare.com',
  );
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  bool _useEmailMode = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/pair');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTypography.displayLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to sync your Healthcare Robot Companion schedule.',
                    style: AppTypography.bodyMedium,
                  ),

                  const SizedBox(height: 28),

                  // Segmented Toggle for Mail vs Username
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useEmailMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _useEmailMode
                                    ? AppColors.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Email Address',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: _useEmailMode
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useEmailMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_useEmailMode
                                    ? AppColors.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Username',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: !_useEmailMode
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: _useEmailMode ? 'EMAIL ADDRESS' : 'USERNAME',
                          hint: _useEmailMode
                              ? 'enter your email...'
                              : 'enter your username...',
                          controller: _identifierController,
                          prefixIcon: _useEmailMode
                              ? Icons.email_rounded
                              : Icons.person_rounded,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your ${_useEmailMode ? "email" : "username"}';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        CustomTextField(
                          label: 'PASSWORD',
                          hint: 'enter password...',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_rounded,
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        CustomButton(
                          label: 'Sign In',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Register Now',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
