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

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Firebase project details
  static const String _projectId = 'chat-a9a04'; // Firebase project ID
  static const String _firebaseScope = 'https://www.googleapis.com/auth/firebase.messaging';

  Future<void> init(BuildContext context) async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Configure Firebase Messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message, context);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _navigateToChatPage(message, context);
      });

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          _onNotificationTap(details, context);
        },
      );

      // Get FCM token
      final String? token = await _firebaseMessaging.getToken();
      print('Firebase Messaging Token: $token');
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
            'payload': '$senderEmail|$senderId',
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

  Future<void> _handleForegroundMessage(RemoteMessage message, BuildContext context) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
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
        payload: message.data['chatId'],
      );
    }
  }

  void _navigateToChatPage(RemoteMessage message, BuildContext context) {
    // Extract chat details from message data
    final String? chatId = message.data['chatId'];
    final String? senderEmail = message.data['senderEmail'];
    final String? senderId = message.data['senderId'];

    if (chatId != null && senderEmail != null && senderId != null) {
      // Navigate directly to the specific chat screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Chat(
            reciverEmail: senderEmail, 
            reciverID: senderId,
          ),
        ),
      );
    }
  }

  void _onNotificationTap(NotificationResponse details, BuildContext context) {
    // Handle notification tap when app is closed or in background
    final String? payload = details.payload;
    
    if (payload != null) {
      // Extract sender details from payload (you might need to modify how this is stored)
      // This is a simplified example and might need adjustment based on your exact data structure
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final String senderEmail = parts[0];
        final String senderId = parts[1];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Chat(
              reciverEmail: senderEmail, 
              reciverID: senderId,
            ),
          ),
        );
      }
    }
  }
}
