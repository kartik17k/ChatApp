import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final List<HelpItem> _helpItems = [
    HelpItem(
      title: "Getting Started",
      description: "Learn how to use the app's basic features and navigation.",
      icon: Icons.help_outline_rounded,
      answer: "Welcome to our chat app! Here are the basic steps to get started:\n\n1. Create a Account:\n2. Chat with user "
    ),
    HelpItem(
      title: "Chat Features",
      description: "Detailed guide on using chat, sending messages, and attachments.",
      icon: Icons.chat_outlined,
      answer: "Chat Features Overview:\n\n1. Sending Messages:\n   - Type your message in the input field\n   - Tap the send button",
    ),
    HelpItem(
      title: "Notifications",
      description: "How to manage and customize your notification settings.",
      icon: Icons.notifications_outlined,
      answer: "Notification Settings:\n\n1. Basic Controls:\n   - Enable/disable notifications",
    ),
    HelpItem(
      title: "Privacy Settings",
      description: "Understanding privacy controls and how to protect your data.",
      icon: Icons.privacy_tip_outlined,
      answer: "Privacy Controls:\n\n1. Account Privacy:\n   - Set online status visibility\n   - Manage profile visibility\n   - Control who can contact you\n\n2. Chat Privacy:\n   - Block unwanted contacts\n   - Hide read receipts\n   - Set message auto-deletion\n\n3. Data Protection:\n   - Manage backup settings\n   - Control media downloads\n   - Set app lock\n\n4. Security Tips:\n   - Regularly update the app\n   - Use strong passwords\n   - Be cautious with shared links\n   - Review privacy settings regularly",
    ),
    HelpItem(
      title: "Troubleshooting",
      description: "Common issues and solutions for app problems.",
      icon: Icons.build_outlined,
      answer: "Common Issues & Solutions:\n\n1. App Crashes:\n   - Clear app cache\n   - Reinstall the app\n   - Update to latest version\n\n2. Message Issues:\n   - Check internet connection\n   - Verify server status\n   - Sign out and back in",
    ),
    HelpItem(
      title: "Contact Support",
      description: "How to get in touch with our support team.",
      icon: Icons.support_agent_outlined,
      answer: "Support Options:\n\n1. Email Support:\n   - Send detailed issue description\n   - Include screenshots",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Help Center",
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Need Help?",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find answers to common questions and get help with using the app.",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ..._helpItems.map((item) => _buildHelpItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          item.description,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              item.answer,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String description;
  final IconData icon;
  final String answer;

  const HelpItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.answer,
  });
}
