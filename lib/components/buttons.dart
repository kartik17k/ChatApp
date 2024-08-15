import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final String text;
  void Function()? onTap;
 Buttons(
      {
        super.key,
        required this.text,
        required this.onTap,
      }
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20)
        ),
        child: Center(
          child: Text(text),
        ),
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 25),
      ),

    );
  }
}
