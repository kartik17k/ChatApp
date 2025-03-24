import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat/services/auth/authgate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return AnimatedSplashScreen(
      splash: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.3,
                width: screenWidth * 0.8,
                child: Icon(
                  Icons.chat_bubble,
                  size: screenWidth * 0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CHAT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      nextScreen: const AuthGate(),
      splashIconSize: screenWidth * 0.8,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
