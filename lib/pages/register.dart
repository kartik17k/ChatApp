import 'package:flutter/material.dart';
import '../components/buttons.dart';
import '../components/textfield.dart';
import '../services/auth/authService.dart';

class Register extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  void Function()? onTap;

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
                  backgroundColor: Colors.red,
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        //single child scroll view to scroll
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.message,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              //welcome message
              Text(
                "Create an account",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 25),
              //email
              MyTextField(
                hinttext: "Email",
                obscuretext: false,
                controller: emailController,
              ),
              const SizedBox(height: 5),
              //password
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
              //sign button
              Buttons(
                onTap: () => register(context),
                text: "Register",
              ),
              const SizedBox(height: 10),
              //register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login Here",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
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
