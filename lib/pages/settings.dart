import 'package:chat/pages/aboutApp.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:flutter/material.dart';
import '../services/auth/authgate.dart';
import '../theme/colors.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  final ChatService chatService = ChatService();

  void delete() async {
    await chatService.deleteUserAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Set background color to cream
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white), // White title text for consistency
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
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
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildSettingsOption(
                  context,
                  title: "About App",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutApp()),
                    );
                  },
                ),
                buildSettingsOption(
                  context,
                  title: "Delete Account",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFFFFF9F0), // Cream color for consistency
                          title: const Text(
                            "Delete Account",
                            style: TextStyle(color: Color(0xFF4E342E)), // Dark brown text color
                          ),
                          content: const Text(
                            "Are you sure you want to delete your account? This action cannot be undone.",
                            style: TextStyle(color: Color(0xFF4E342E)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                delete(); // Execute the delete function
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthGate(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent, // Red button for Delete
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsOption(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF77F64), // Coral background color for options
      ),
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white, // White text for option items
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
