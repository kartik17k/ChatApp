import 'dart:io';

import 'package:chat/firebase_options.dart';
import 'package:chat/splashScreen.dart';
import 'package:chat/theme/light.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MyApp(analytics: analytics),
    )
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  
  const MyApp({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, 
      home: const SplashScreen(),
      theme: creamTheme,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
