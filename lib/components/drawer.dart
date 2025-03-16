import 'package:chat/pages/settings.dart';
import 'package:flutter/material.dart';
import '../services/auth/authService.dart';
import '../theme/colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final authService = AuthService();
    Navigator.pop(context); // Close drawer before logging out
    authService.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF9F0), // Cream background color
      child: Column(
        children: [
          // Drawer Header with Icon
          DrawerHeader(
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.message,
                color: Colors.white, // White icon for contrast
                size: 80,
              ),
            ),
          ),

          // Menu items
          ListTile(
            title: const Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4E342E), // Dark brown for text
              ),
            ),
            leading: const Icon(Icons.home, size: 28, color: Color(0xFF4E342E)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4E342E), // Dark brown for text
              ),
            ),
            leading: const Icon(Icons.settings, size: 28, color: Color(0xFF4E342E)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  Settings(),
                ),
              );
            },
          ),
          const Spacer(), // Pushes Logout to the bottom

          // Logout button
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ListTile(
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 18,
                ),
              ),
              leading: const Icon(
                Icons.logout,
                size: 28,
                color: Colors.redAccent,
              ),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
