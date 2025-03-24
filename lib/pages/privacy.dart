import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PrivacySettings extends StatefulWidget {
  const PrivacySettings({super.key});

  @override
  State<PrivacySettings> createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool _showLastSeen = true;
  bool _showOnlineStatus = true;
  bool _readReceipts = true;
  bool _blockContacts = false;
  bool _blockStrangers = false;
  bool _messageAutoDelete = false;
  int _messageAutoDeleteDuration = 7;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreviews = true;
  bool _showBadge = true;

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
          "Privacy Settings",
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
            _buildPrivacySection(
              title: "Profile Privacy",
              options: [
                _buildSwitchOption(
                  title: "Show Last Seen Status",
                  subtitle: "Show your last seen time to contacts",
                  value: _showLastSeen,
                  onChanged: (value) {
                    setState(() => _showLastSeen = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Show Online Status",
                  subtitle: "Show when you're online to contacts",
                  value: _showOnlineStatus,
                  onChanged: (value) {
                    setState(() => _showOnlineStatus = value);
                  },
                ),
              ],
            ),
            _buildPrivacySection(
              title: "Message Privacy",
              options: [
                _buildSwitchOption(
                  title: "Show Read Receipts",
                  subtitle: "Show when you've read messages",
                  value: _readReceipts,
                  onChanged: (value) {
                    setState(() => _readReceipts = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Auto-Delete Messages",
                  subtitle: "Automatically delete messages after",
                  value: _messageAutoDelete,
                  onChanged: (value) {
                    setState(() => _messageAutoDelete = value);
                  },
                  trailing: _messageAutoDelete
                      ? Text("$_messageAutoDeleteDuration days")
                      : null,
                ),
                if (_messageAutoDelete)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Slider(
                      value: _messageAutoDeleteDuration.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '$_messageAutoDeleteDuration days',
                      onChanged: (value) {
                        setState(() => _messageAutoDeleteDuration = value.toInt());
                      },
                    ),
                  ),
              ],
            ),
            _buildPrivacySection(
              title: "Blocking",
              options: [
                _buildSwitchOption(
                  title: "Block Contacts",
                  subtitle: "Block specific contacts from contacting you",
                  value: _blockContacts,
                  onChanged: (value) {
                    setState(() => _blockContacts = value);
                  },
                ),
                _buildSwitchOption(
                  title: "Block Strangers",
                  subtitle: "Prevent non-contacts from messaging you",
                  value: _blockStrangers,
                  onChanged: (value) {
                    setState(() => _blockStrangers = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({
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
    Widget? trailing,
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
                trailing ??
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
}
