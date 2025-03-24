import 'package:flutter/material.dart';
import '../services/chat/chatservice.dart';
import '../services/auth/authgate.dart';
import '../theme/colors.dart';
import '../services/auth/authService.dart';
import '../services/theme/theme_service.dart';
import 'aboutApp.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Settings",
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
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).appBarTheme.iconTheme?.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutApp()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).cardTheme.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        AuthService().getCurrentUser()!.email!
                            .split('@')[0][0]
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthService().getCurrentUser()!.email!
                        .split('@')[0],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AuthService().getCurrentUser()!.email!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                const SizedBox(height: 16),
                _buildSettingsSection(
                  context: context,
                  title: "Account",
                  options: [
                    _SettingsOption(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      subtitle: "Manage your notification preferences",
                      onTap: () {
                        // TODO: Implement notifications settings
                      },
                    ),
                    _SettingsOption(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy",
                      subtitle: "Manage your privacy settings",
                      onTap: () {
                        // TODO: Implement privacy settings
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  context: context,
                  title: "App",
                  options: [
                    _SettingsOption(
                      icon: Icons.dark_mode_outlined,
                      title: "Theme",
                      subtitle: "Change app theme",
                      onTap: () async {
                        final themeService = Provider.of<ThemeService>(context, listen: false);
                        final currentMode = themeService.themeNotifier.value;
                        
                        final newMode = await showDialog<ThemeMode>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Theme Mode"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.light_mode_outlined),
                                  title: const Text("Light"),
                                  trailing: Radio<ThemeMode>(
                                    value: ThemeMode.light,
                                    groupValue: currentMode,
                                    onChanged: (value) {
                                      Navigator.pop(context, value);
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.dark_mode_outlined),
                                  title: const Text("Dark"),
                                  trailing: Radio<ThemeMode>(
                                    value: ThemeMode.dark,
                                    groupValue: currentMode,
                                    onChanged: (value) {
                                      Navigator.pop(context, value);
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.brightness_auto_outlined),
                                  title: const Text("System"),
                                  trailing: Radio<ThemeMode>(
                                    value: ThemeMode.system,
                                    groupValue: currentMode,
                                    onChanged: (value) {
                                      Navigator.pop(context, value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );

                        if (newMode != null) {
                          await themeService.setThemeMode(newMode);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  context: context,
                  title: "Help",
                  options: [
                    _SettingsOption(
                      icon: Icons.help_outline_rounded,
                      title: "Help Center",
                      subtitle: "Get help with using the app",
                      onTap: () {
                        // TODO: Implement help center
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final chatService = ChatService();
                        await chatService.deleteUserAccount();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthGate(),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to delete account: ${e.toString()}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text(
                      "Delete Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...options,
      ],
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
