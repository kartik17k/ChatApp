import 'package:chat/components/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/textfield.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  State<ForgetPage> createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> forgetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      _showDialog(
        title: "Success",
        content: "Email sent successfully.",
        icon: Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      );
      emailController.clear();
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      _showDialog(
        title: "Error",
        content: e.message.toString(),
        icon: Icons.error,
        color: Theme.of(context).colorScheme.secondary,
      );
      emailController.clear();
    }
  }

  void _showDialog({required String title, required String content, required IconData icon, required Color color}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
              style: TextButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter your email to send the link",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
              hinttext: "Email",
              obscuretext: false,
              controller: emailController,
            ),
            const SizedBox(height: 10),
            Buttons(
              text: "Send",
              onTap: forgetPassword,
            ),
            const SizedBox(height: 20),
            // Optional: Add a back button or a similar navigation option
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Go back to the previous page
              },
              child: Text(
                "Back to Login",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
