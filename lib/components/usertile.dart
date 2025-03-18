import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? ontap;
  final int unreadCount;

  const UserTile({
    super.key, 
    required this.text, 
    required this.ontap, 
    this.unreadCount = 0
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Icons
            Icon(Icons.person),

            SizedBox(width: 10),

            // User name with optional bold and unread count
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text, 
                      style: TextStyle(
                        fontWeight: unreadCount > 0 
                          ? FontWeight.bold 
                          : FontWeight.normal
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount', 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
