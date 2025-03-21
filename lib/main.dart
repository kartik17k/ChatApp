import 'dart:io';
  
import 'package:chat/firebase_options.dart';
import 'package:chat/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:chat/services/notification/notification_service.dart';
import 'package:chat/services/auth/authgate.dart';
import 'package:chat/pages/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  // Initialize notification services
  final notificationService = NotificationService();
  await notificationService.initNotifications();
  
  // Setup highlight notification handling
  notificationService.setupHighlightNotificationHandling();

  // Check if app was launched from a notification
  final prefs = await SharedPreferences.getInstance();
  final bool wasLaunchedFromNotification = prefs.getBool('launched_from_notification') ?? false;
  
  // Clear the flag after reading
  await prefs.remove('launched_from_notification');
  
  runApp(

        MyApp(
        analytics: analytics, 
        notificationService: notificationService,
        wasLaunchedFromNotification: wasLaunchedFromNotification,
      ),

  );
}

class MyApp extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final NotificationService notificationService;
  final bool wasLaunchedFromNotification;
  
  const MyApp({
    super.key, 
    required this.analytics, 
    required this.notificationService,
    required this.wasLaunchedFromNotification,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Initialize notification service with context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notificationService.init(context);
      
      // Check for any pending notifications
      widget.notificationService.checkPendingNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the initial route based on notification launch
    Widget initialRoute = widget.wasLaunchedFromNotification 
      ? _buildNotificationLaunchRoute() 
      : const SplashScreen();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, 
      home: initialRoute,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: widget.analytics),
      ],
    );
  }

  // Method to build the route when launched from notification
  Widget _buildNotificationLaunchRoute() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final prefs = snapshot.data!;
          final String? senderEmail = prefs.getString('pending_notification_sender_email');
          final String? senderId = prefs.getString('pending_notification_sender_id');

          // Clear the stored notification data
          prefs.remove('pending_notification_sender_email');
          prefs.remove('pending_notification_sender_id');

          if (senderEmail != null && senderId != null) {
            // Navigate directly to chat
            return Chat(
              reciverEmail: senderEmail, 
              reciverID: senderId,
              allowBack: false,
            );
          }
        }
        
        // Fallback to AuthGate if no notification data
        return AuthGate();
      },
    );
  }
}
