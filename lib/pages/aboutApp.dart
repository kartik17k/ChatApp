import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          "About App",
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: surfaceColor,
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
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Social Chat",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 32),
                _buildSection(
                  title: "Description",
                  content: "A modern, real-time chat application built with Flutter and Firebase. Connect with friends, send messages, and share media in a beautiful, intuitive interface.",
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: "Features",
                  content: "• Real-time messaging\n• Typing indicators\n• Message delivery status\n• Unread message tracking\n• User profiles\n• Secure authentication\n• Push notifications\n• Modern UI/UX",
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: "Technology",
                  content: "• Flutter\n• Firebase Firestore\n• Firebase Authentication\n• Cloud Functions\n• Cloud Storage",
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: "Privacy Policy",
                  content: "Your privacy is important to us. We do not collect or share any personal information without your explicit consent.",
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: "Terms of Service",
                  content: "By using this application, you agree to our terms of service and privacy policy.",
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
