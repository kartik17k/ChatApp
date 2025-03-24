import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat/chatservice.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreviews = true;
  bool _showBadge = true;
  bool _showInStatusBar = true;
  bool _showInLockScreen = true;
  bool _groupNotifications = true;
  int _priority = 2; // 0: Low, 1: Default, 2: High
  bool _notifyForUnread = true;
  bool _showBadgeForUnread = true;
  double _unreadCountThreshold = 5;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Notifications",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(
              title: "Basic Settings",
              options: [
                _buildSwitchOption(
                  title: "Enable Notifications",
                  subtitle: "Receive notifications for new messages",
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    if (value && !_notificationsEnabled) {
                      await _requestNotificationPermission();
                    }
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Sound",
                  subtitle: "Play sound for new notifications",
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Vibration",
                  subtitle: "Vibrate for new notifications",
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() => _vibrationEnabled = value);
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "Display Settings",
              options: [
                _buildSwitchOption(
                  title: "Show Previews",
                  subtitle: "Show message content in notifications",
                  value: _showPreviews,
                  onChanged: (value) {
                    setState(() => _showPreviews = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Show Badge",
                  subtitle: "Show unread message count on app icon",
                  value: _showBadge,
                  onChanged: (value) {
                    setState(() => _showBadge = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Show in Status Bar",
                  subtitle: "Show notification icon in status bar",
                  value: _showInStatusBar,
                  onChanged: (value) {
                    setState(() => _showInStatusBar = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Show on Lock Screen",
                  subtitle: "Show notifications on lock screen",
                  value: _showInLockScreen,
                  onChanged: (value) {
                    setState(() => _showInLockScreen = value);
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "Advanced Settings",
              options: [
                _buildListOption(
                  title: "Notification Priority",
                  subtitle: "Set notification priority",
                  value: _priority,
                  onChanged: (value) {
                    setState(() => _priority = value);
                  },
                  items: const [
                    'Low',
                    'Default',
                    'High',
                  ],
                ),
                _buildSwitchOption(
                  title: "Group Notifications",
                  subtitle: "Group notifications by conversation",
                  value: _groupNotifications,
                  onChanged: (value) {
                    setState(() => _groupNotifications = value);
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "Unread Messages",
              options: [
                _buildSwitchOption(
                  title: "Notify for Unread Messages",
                  subtitle: "Receive notifications for unread messages",
                  value: _notifyForUnread,
                  onChanged: (value) {
                    setState(() => _notifyForUnread = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Show Badge for Unread",
                  subtitle: "Show badge count for unread messages",
                  value: _showBadgeForUnread,
                  onChanged: (value) {
                    setState(() => _showBadgeForUnread = value);
                  },
                ),
                _buildSliderOption(
                  title: "Unread Count Threshold",
                  subtitle: "Minimum unread messages before notification",
                  value: _unreadCountThreshold,
                  onChanged: (value) {
                    setState(() => _unreadCountThreshold = value);
                  },
                  min: 1,
                  max: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...options,
      ],
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
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
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListOption({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return ListTile(
                      title: Text(item),
                      trailing: Radio<int>(
                        value: index,
                        groupValue: value,
                        onChanged: (value) {
                          Navigator.pop(context);
                          onChanged(value!);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
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
                Text(
                  items[value],
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderOption({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                    Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  label: value.toInt().toString(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
