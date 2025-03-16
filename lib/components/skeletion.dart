import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFFFE8A3),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.grey.shade300, // Placeholder for avatar
            ),
          ),
          title: Container(
            width: 100,
            height: 16,
            color: Colors.grey.shade300, // Placeholder for title
          ),
          subtitle: Container(
            width: 150,
            height: 14,
            color: Colors.grey.shade300, // Placeholder for subtitle
          ),
        ),
      ),
    );
  }
}
