import 'package:flutter/material.dart';
import '../components/buttons.dart';
import '../components/textfield.dart';
import '../services/auth/authService.dart';

class Register extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final void Function()? onTap;

  Register({super.key, required this.onTap});

  void register(BuildContext context) async {
    final authService = AuthService();
    if (passwordController.text == confirmpasswordController.text) {
      try {
        await authService.signUpWithEmailPassword(
            emailController.text, passwordController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text("Error"),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Use secondary color from theme
                  foregroundColor: Colors.white, // Text color
                ),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 10),
              Text("Warning"),
            ],
          ),
          content: Text("Passwords don't match"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Use background color from theme
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.message,
                size: 50,
                color: Theme.of(context).colorScheme.primary, // Primary color from theme
              ),
              const SizedBox(height: 10),
              // Welcome message
              Text(
                "Create an account",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, // Primary color from theme
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
              // Email input
              MyTextField(
                hinttext: "Email",
                obscuretext: false,
                controller: emailController,
              ),
              const SizedBox(height: 5),
              // Password input
              MyTextField(
                hinttext: "Password",
                obscuretext: true,
                controller: passwordController,
              ),
              MyTextField(
                hinttext: "Confirm password",
                obscuretext: true,
                controller: confirmpasswordController,
              ),
              const SizedBox(height: 25),
              // Register button
              Buttons(
                onTap: () => register(context),
                text: "Register",
              ),
              const SizedBox(height: 10),
              // Redirect to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, // Secondary color from theme
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login Here",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary, // Inverse primary from theme
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
