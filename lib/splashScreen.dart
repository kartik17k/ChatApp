import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat/services/auth/authgate.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return AnimatedSplashScreen(
      splash: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.3, // 60% of screen height for Lottie animation
                width: screenWidth * 0.8, // 80% of screen width
                child: LottieBuilder.asset(
                  'images/chat.json',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      nextScreen: AuthGate(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      splashIconSize: screenWidth * 0.8, // Adjust splash icon size to be responsive
      duration: 3000, // Duration of the splash screen
      splashTransition: SplashTransition.fadeTransition, // Choose a transition
    );
  }
}

