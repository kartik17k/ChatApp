import 'package:flutter/material.dart';
import '../theme/colors.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? ontap;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isOwnMessage;
  final String userId;
  final String currentUserId;

  const UserTile({
    super.key, 
    required this.text, 
    required this.ontap, 
    required this.userId,
    required this.currentUserId,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageTime,
    this.isOwnMessage = false,
  });

  String _getTimeString() {
    if (lastMessageTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inDays > 7) {
      return '${lastMessageTime!.day}/${lastMessageTime!.month}/${lastMessageTime!.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'avatar_${userId}_${currentUserId}',
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 24,
                    child: Text(
                      text.split('@')[0].split('').first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              text.split('@')[0],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: unreadCount > 0 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              ),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastMessageTime != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _getTimeString(),
                              style: TextStyle(
                                color: subtleTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                lastMessage!,
                                style: TextStyle(
                                  color: unreadCount > 0 
                                    ? textColor 
                                    : subtleTextColor,
                                  fontSize: 14,
                                  fontWeight: unreadCount > 0 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
