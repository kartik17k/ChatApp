import 'package:flutter/material.dart';
import '../components/textfield.dart';
import '../services/auth/authService.dart';
import '../theme/colors.dart';

class Register extends StatefulWidget {
  final void Function()? onTap;

  const Register({super.key, this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog(
        title: "Password Mismatch",
        message: "The passwords you entered don't match. Please try again.",
        icon: Icons.warning_amber_rounded,
        color: warningColor,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      _showErrorDialog(
        title: "Password Too Short",
        message: "Password must be at least 6 characters long.",
        icon: Icons.error_outline,
        color: errorColor,
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      _showErrorDialog(
        title: "Invalid Email",
        message: "Please enter a valid email address.",
        icon: Icons.error_outline,
        color: errorColor,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      await authService.signUpWithEmailPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      _showErrorDialog(
        title: "Registration Failed",
        message: e.toString(),
        icon: Icons.error_outline,
        color: errorColor,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: textColor,
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_add_outlined,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join our community today",
                          style: TextStyle(
                            color: subtleTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  MyTextField(
                    hintText: "Email",
                    labelText: "Email Address",
                    obscureText: false,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: textColor,
                    ),
                    errorText: _isLoading ? null : null,
                    helperText: "Enter your email address",
                    onChanged: (value) {
                      if (_isLoading) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    hintText: "Password",
                    labelText: "Password",
                    obscureText: true,
                    controller: passwordController,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: textColor,
                    ),
                    errorText: _isLoading ? null : null,
                    helperText: "Minimum 6 characters",
                    onChanged: (value) {
                      if (_isLoading) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    hintText: "Confirm Password",
                    labelText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPasswordController,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: textColor,
                    ),
                    errorText: _isLoading ? null : null,
                    helperText: "Re-enter your password",
                    onChanged: (value) {
                      if (_isLoading) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: widget.onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
