import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ChatBubbleSkeleton extends StatelessWidget {
  final bool isCurrentUser;

  const ChatBubbleSkeleton({
    super.key,
    this.isCurrentUser = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(15.0),
        width: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
