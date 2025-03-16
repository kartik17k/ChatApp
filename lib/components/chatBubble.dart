import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final Color userColor; // Color for user's messages
  final Color botColor; // Color for bot's messages

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.userColor = const Color(0xFFF77F64), // Default color for user's messages
    this.botColor = const Color(0xFFE5CFC0), // Default color for bot's messages
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isCurrentUser ? userColor : botColor, // Use the respective color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isCurrentUser ? Radius.circular(12) : Radius.circular(12),
            bottomRight: isCurrentUser ? Radius.circular(12) : Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          message,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
