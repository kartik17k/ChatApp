import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hinttext;
  final bool obscuretext;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const MyTextField(
      {
        super.key,
        required this.hinttext,
        required this.obscuretext,
        required this.controller,
        this.focusNode,
      }
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: hinttext,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                  borderRadius: BorderRadius.circular(20)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(20)
            ),
          ),
          obscureText: obscuretext,
          controller: controller,
          focusNode: focusNode,
        ),
    );
  }
}
