import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String time;
  final bool isRead;
  final bool isDelivered;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.time,
    this.isRead = false,
    this.isDelivered = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onDelete != null ? () => _showDeleteDialog(context) : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: isCurrentUser ? 64 : 8,
            right: isCurrentUser ? 8 : 64,
            bottom: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isCurrentUser ? primaryColor : surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
              bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : textColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white70 : subtleTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onDelete != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showDeleteDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: isCurrentUser 
                              ? Colors.white.withOpacity(0.7)
                              : subtleTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Message',
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: TextStyle(color: subtleTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
