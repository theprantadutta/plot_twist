// lib/application/services/notification_service.dart
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../data/firestore/firestore_service.dart';
import '../../presentation/pages/detail/movie_detail_screen.dart';
import '../../presentation/pages/detail/tv_show_detail_screen.dart';

// This is our global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessage(RemoteMessage? message) async {
  if (message?.notification != null) {
    debugPrint(
      "Background notification received: ${message!.notification!.title}",
    );
  }
}

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // The main initialization method
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    // Get and save the FCM token
    await getFCMToken();

    // Setup listeners
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
    _handleForegroundMessages();
    _handleBackgroundTaps();
    _handleTerminatedTaps();
  }

  // Get the FCM device token and save it to Firestore
  static Future<void> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("Firebase FCM Token: $token");
        // Save the token to the user's document
        await FirestoreService().saveFcmToken(token);
      }
    } catch (e) {
      debugPrint("Failed to get FCM token: $e");
    }
  }

  // Handles showing a notification when the app is in the foreground
  static void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.title}");
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  // Handles when a user taps a notification and the app is in the background
  static void _handleBackgroundTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message == null) return;
      debugPrint("Notification tapped from background");
      _navigateToScreenFromPayload(message.data);
    });
  }

  // Handles when a user taps a notification and the app was terminated
  static Future<void> _handleTerminatedTaps() async {
    final RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint("Notification tapped from terminated state");
      _navigateToScreenFromPayload(initialMessage.data);
    }
  }

  // --- LOCAL NOTIFICATIONS SETUP ---

  static Future<void> localNotificationInit() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  // This is called when a user taps a local notification (shown in the foreground)
  static void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      _navigateToScreenFromPayload(data);
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'plot_twists_channel',
          'PlotTwists Notifications',
          channelDescription: 'Notifications for new releases and updates.',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // --- THE SMART NAVIGATION LOGIC ---
  static void _navigateToScreenFromPayload(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final String? type = data['type'];
    final String? idString = data['id'];

    if (type == null || idString == null) return;

    final int? mediaId = int.tryParse(idString);
    if (mediaId == null) return;

    debugPrint("Navigating to $type with ID $mediaId");

    Widget screen;
    if (type == 'movie') {
      screen = MovieDetailScreen(mediaId: mediaId);
    } else if (type == 'tv') {
      screen = TvShowDetailScreen(mediaId: mediaId);
    } else {
      // You can add more types later, like 'list' or 'profile'
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
