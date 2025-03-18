import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' show Client;
import 'package:chat/main.dart'; // Import the global navigator key
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat/services/auth/authgate.dart'; // Import AuthGate

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();
  print("🔔 Handling a background message: ${message.messageId}");

  // Store message data for later use
  final String? chatId = message.data['chatId'];
  final String? senderEmail = message.data['senderEmail'];
  final String? senderId = message.data['senderId'];

  if (chatId != null && senderEmail != null && senderId != null) {
    // Store message data to be used when app is opened
    await _storeNotificationData(message);
  }
}

// Utility method to store notification data
Future<void> _storeNotificationData(RemoteMessage message) async {
  // Use shared preferences to store notification data
  final prefs = await SharedPreferences.getInstance();
  
  // Store notification details
  await prefs.setString('pending_notification_chat_id', message.data['chatId'] ?? '');
  await prefs.setString('pending_notification_sender_email', message.data['senderEmail'] ?? '');
  await prefs.setString('pending_notification_sender_id', message.data['senderId'] ?? '');
  
  // Set a flag to indicate app was launched from notification
  await prefs.setBool('launched_from_notification', true);
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Firebase project details
  static const String _projectId = 'chat-a9a04'; // Firebase project ID
  static const String _firebaseScope = 'https://www.googleapis.com/auth/firebase.messaging';

  // New method for initializing notifications
  Future<void> initNotifications() async {
    print('🔔 Initializing Notifications');
    
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      final String? token = await _firebaseMessaging.getToken();
      print('🔔 Firebase Messaging Token: $token');
    } else {
      print('🚫 Notification permissions not granted');
    }
  }

  // New method for setting up highlight notification handling
  void setupHighlightNotificationHandling() {
    print('🔔 Setting up Highlight Notification Handling');
    
    // Configure how to handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Received a foreground message');
      
      // Check if the message contains a highlight notification
      if (message.data['type'] == 'highlight') {
        // Display a local notification
        _showHighlightNotification(message);
      }
    });
  }

  // Helper method to show highlight notifications
  void _showHighlightNotification(RemoteMessage message) async {
    // Create a local notification for highlight messages
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
        AndroidNotificationDetails(
      'highlight_channel', 
      'Highlight Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = 
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? 'New Highlight', 
      message.notification?.body ?? 'You have a new highlight', 
      platformChannelSpecifics,
      payload: message.data['payload'] ?? '',
    );
  }

  Future<void> init(BuildContext context) async {
    print('🔔 Initializing Notification Service');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true, // Add this for iOS
      );

      print('🔔 Notification Permission Status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Configure Firebase Messaging
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('🔔 Received message in foreground: ${message.notification?.title}');
          _handleForegroundMessage(message, context);
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('🔔 Message opened app: ${message.notification?.title}');
          _navigateToChatPage(message);
        });

        // Check for initial message when app is launched from terminated state
        await _checkInitialMessage();

        // Initialize local notifications with a default channel
        const AndroidInitializationSettings initializationSettingsAndroid = 
            AndroidInitializationSettings('@mipmap/ic_launcher');
        final InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
        );
        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse details) {
            print('🔔 Notification tapped');
            _onNotificationTap(details);
          },
        );

        // Create a default notification channel
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        // Get FCM token
        final String? token = await _firebaseMessaging.getToken();
        print('🔔 Firebase Messaging Token: $token');
      } else {
        print('🚫 Notification permissions not granted');
      }
    } catch (e) {
      print('🚨 Error initializing notifications: $e');
    }
  }

  void _onNotificationTap(NotificationResponse details) {
    print('🔔 Notification tapped with payload: ${details.payload}');
    
    final String? payload = details.payload;
    
    if (payload != null) {
      // Extract sender details from payload
      final parts = payload.split('|');
      if (parts.length >= 3) {
        final String senderEmail = parts[0];
        final String senderId = parts[1];
        final String chatId = parts[2];

        print('🔔 Extracted notification details: '
            'Sender Email: $senderEmail, '
            'Sender ID: $senderId, '
            'Chat ID: $chatId');

        // Trigger navigation when app is opened
        _triggerChatNavigation(senderEmail, senderId);
      } else {
        print('🚨 Invalid notification payload format');
      }
    } else {
      print('🚨 No payload received in notification');
    }
  }

  // Add a method to handle initial notification when app is launched from a terminated state
  Future<void> _checkInitialMessage() async {
    print('🔔 Checking for initial message');
    
    // Check if the app was opened from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      print('🔔 App opened from terminated state with message');
      await _storeNotificationData(initialMessage);
    }
  }

  void _navigateToChatPage(RemoteMessage message) {
    // Extract chat details from message data
    final String? chatId = message.data['chatId'];
    final String? senderEmail = message.data['senderEmail'];
    final String? senderId = message.data['senderId'];

    if (chatId != null && senderEmail != null && senderId != null) {
      // Trigger navigation when app is opened
      _triggerChatNavigation(senderEmail, senderId);
    }
  }

  // New method to handle navigation with a back option
  void navigateToChatOrHome(BuildContext context, {
    String? senderEmail, 
    String? senderId, 
    bool allowBack = false
  }) {
    if (senderEmail != null && senderId != null) {
      // Navigate to chat with an option to go back
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Chat(
            reciverEmail: senderEmail, 
            reciverID: senderId,
            allowBack: allowBack, // Pass the back navigation option
          ),
        ),
      );
    } else {
      // If no sender details, navigate to home page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthGate()), 
        (route) => false
      );
    }
  }

  void _triggerChatNavigation(String senderEmail, String senderId, {bool allowBack = false}) {
    // Use the global navigator key to navigate
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (context) => Chat(
            reciverEmail: senderEmail, 
            reciverID: senderId,
            allowBack: allowBack, // Pass the back navigation option
          ),
        ),
      );
    } else {
      print('🚨 Navigator key is null. Cannot navigate to chat.');
    }
  }

  // Method to check for pending notifications when app starts
  Future<void> checkPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? senderEmail = prefs.getString('pending_notification_sender_email');
    final String? senderId = prefs.getString('pending_notification_sender_id');
    final bool? launchedFromNotification = prefs.getBool('launched_from_notification');
    
    if (senderEmail != null && senderId != null && launchedFromNotification != null && launchedFromNotification) {
      print('🔔 Found pending notification, navigating to chat');
      _triggerChatNavigation(senderEmail, senderId);
      
      // Clear the stored notification data
      await prefs.remove('pending_notification_sender_email');
      await prefs.remove('pending_notification_sender_id');
      await prefs.remove('launched_from_notification');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message, BuildContext context) async {
    print('🔔 Got a message whilst in the foreground!');
    print('🔔 Message data: ${message.data}');

    if (message.notification != null) {
      print('🔔 Message also contained a notification: ${message.notification}');
      
      // Show local notification when app is in foreground
      const AndroidNotificationDetails androidPlatformChannelSpecifics = 
          AndroidNotificationDetails(
        'chat_channel',
        'Chat Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      final NotificationDetails platformChannelSpecifics = 
          NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: '${message.data['senderEmail']}|${message.data['senderId']}|${message.data['chatId']}',
      );
    }
  }

  Future<void> sendMessageNotification({
    required String receiverToken,
    required String senderName,
    required String message,
    required String chatId,
    required String senderId,
    required String senderEmail,
  }) async {
    if (receiverToken.isEmpty) {
      print('Error: Receiver token is empty');
      return;
    }

    try {
      // Get authenticated HTTP client
      final client = await _getAuthenticatedClient();

      // Construct V1 API request body
      final body = {
        'message': {
          'token': receiverToken,
          'notification': {
            'title': 'New Message from $senderName',
            'body': message,
          },
          'data': {
            'chatId': chatId,
            'senderId': senderId,
            'senderEmail': senderEmail,
            'type': 'message',
            'payload': '$senderEmail|$senderId|$chatId',
          },
          'android': {
            'priority': 'high',
          }
        }
      };

      // Send notification via V1 API
      final response = await client.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get an authenticated HTTP client for V1 API
  Future<Client> _getAuthenticatedClient() async {
    final serviceAccountCredentials = auth.ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "chat-a9a04",
      "private_key_id": "dba9755e4741a026b1e8a64fed79a6d16c2291b2",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDNThk3e3zaYkMB\nYoc/eRGA1xOmhS9ZolHIzupq8w+SeWI6lxnBU0GxB9/N7rEgGWTbKj5XCHLhvbPX\ntKEfMYlc8UPxssjSJCCVxUKyH4NtHoUudQjHLQxCK6dKcYMweJQjpGd3nMRMjCIO\nX0R+cAJQDgGGlNvn4VjBCjk1AGgU+ssb8Vd4tFBt422FPm4t38LthGpdfhShriu+\nyCmJO+YYq0ZL5StWMkA+IPy6gWMW6eRgRCj80pE1ZLWY3AaFtl/GwLOGZGuhcFr5\nJ95vPUsy0ASYwIGqNRWOOJ0OdHXakG1PDJXMDbx8nst7qIGat/hCJkfP4RDOgPzM\n8uWpeZGBAgMBAAECggEAEDBD/W5SUPywizppWbrtLhCc2bjkxpeYWqeI2ngMq/XA\nUMhmB9V4d5dxsVD3TIWpaz1bKbez1KhbDFDk54sbaWW+Ksp4hVbDRFaymfhcKk2J\nc46s64UE027nw7n2/ep0G+oJx+e89CA/Szd933kWOu5vy7HkiSs+uVyvWBuObsuX\nc2BYX1RaPEGr6S5eFzpsfmfb4G3p2H0VP7//9BRydUCBfmj5a/pt+79Y3734/fYN\nRoyIBIDhT3wu/cUkoBSv+cftr6YR9qs1Kayvdc+CA0VGLrehekhCJAyVvgIarunP\nUE9wzTD8qR8Ckj5dya9td7hv7RK4gJAkrm2Ox4yCFQKBgQDQZ/FoFvkRTI5vJfFj\nLO6qrcGIGPNKvx9qKVUse4G9jO//ivlspiYbNHfY4c2rdV8RaDyP0ezHM39KxpI/\nKlTxlUNkeRtarHF0F32RLeDMUqTxuxWh/J5YTN9VNHSN8S3yBnWwEVdwcaF8dbbN\n8BrqBBF2kO3GWi4jFhDUufGWbwKBgQD8MN04iJ3TWmfCs6sSF1t8HHjgG1YVDGeq\no5rdiwHp2DijfpCzbZ+Oum6JsZ+eI2oRNZl2RiYmMpF90EiR+d9r27nfIbUc8RtP\n/f4Qsb/6b7es5iGgBmiQjlh7W+obi/aO7ZDZHXyGjzVV9mzSGOSIVPCfPGiJhQ1i\ni5dAljLPDwKBgQChfrqaP5sYJawGQ2/Pu4Ti7CyZa0Q0uu/8EzV2d+qs2SctbiMk\nZ4gF8t2gSjJXWGeoFI9Bn5oNL0HHzyKLIiGa52DG3fYtiI2OOZnLQ7L8glphG+mC\nkkCeCkvSOgjL6YYCE7FlE7sfXl6WFJ3o7dPdXfOuXlZzK3SvKa03OzQTrwKBgEhP\nHm8CRPZ/2nZqG6fhSJrqcwIW9HSujN7RcCsLm23YUE0YkhbQXMqIy/7xDgpCrzvl\n+W1/KZsULsE7QkOQuK3tX3sJ6Cs3OpSSCBHzVU9STwDlL0j57WtdVSNxtEtXs0dB\n+KE4IidW0n0mXgdTmds5N5EAuhyMKM1Tpvee2UyjAoGBAJhRJZbver43gG3QUoj+\nk0/VT8pZmKqR4a2TcjfUtS398JSfDhmtgqcN/t3alRfjryTteMURqcdxPNp++dRs\naipf0WpsRX2zxoA8iZaRZPcIgEV1gZbTm9ab/iz04o0NMDsmyc0deynlkpNdoPKm\nXUi0ap0yhgx3RJ30iVmV/Iu/\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-uzxra@chat-a9a04.iam.gserviceaccount.com",
      "client_id": "104706022019475041732",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-uzxra%40chat-a9a04.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    // Get authenticated client
    return await auth.clientViaServiceAccount(
      serviceAccountCredentials, 
      [_firebaseScope]
    );
  }
}
