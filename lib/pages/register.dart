import 'package:flutter/material.dart';
import '../components/textfield.dart';
import '../components/buttons.dart';
import '../services/auth/authService.dart';
import '../theme/theme.dart';
import 'login.dart';
import 'home.dart'; // Import the Home page

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      // AuthGate will handle navigation
    } catch (e) {
      if (e is Exception) {
        _showErrorDialog(e.toString());
      } else {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Text(
              "Error",
              style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and welcome message
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your account",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email field
                  MyTextField(
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  MyTextField(
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  MyTextField(
                    hintText: 'Confirm password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Register button
                  Buttons(
                    text: _isLoading ? 'Loading...' : 'Sign Up',
                    onTap: _register,
                  ),
                  const SizedBox(height: 16),

                  // Login button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
