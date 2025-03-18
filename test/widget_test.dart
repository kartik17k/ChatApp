// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:chat/services/notification/notification_service.dart';

import 'package:chat/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create mock instances for required parameters
    final analytics = FirebaseAnalytics.instance;
    final notificationService = NotificationService();
    final wasLaunchedFromNotification = false;

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      analytics: analytics,
      notificationService: notificationService,
      wasLaunchedFromNotification: wasLaunchedFromNotification,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
