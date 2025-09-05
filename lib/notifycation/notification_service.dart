import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utilities/global_methods.dart';
import '../constants.dart';

/// Plugin local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Background handler FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Notification Service (singleton)
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Init notifications
  Future<void> init() async {
    // Request permission iOS
    await _messaging.requestPermission();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Init local notification plugin
    await _setupLocalNotification();

    // Foreground → show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background → tap vào FCM notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 BACKGROUND tapped: ${message.data}");
    });

    // App killed → mở bằng notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("📲 Opened from terminated: ${initialMessage.data}");
      _navigateToScreen(
        initialMessage.data['screen'] ?? '',
        initialMessage.data,
      );
    }
  }

  /// Setup local notification channel
  Future<void> _setupLocalNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final screen = data['screen'] ?? '';
          _navigateToScreen(screen, data);
        }
      },
    );
    const channel = AndroidNotificationChannel(
      'chat_channel', // id
      'Chat Notifications', // name
      description: 'Thông báo tin nhắn',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle FCM in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint("📩 Foreground message: ${message.data}");

    final data = message.data;
    final title = data['title'] ?? 'No title';
    final body = data['body'] ?? 'No body';

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_sound'),
        ),
      ),
      payload: jsonEncode(data), // 👈 dùng để xử lý khi tap
    );
  }


  /// Navigate based on screen key
  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    switch (screen) {
      case 'chat':
        navigatorKey.currentState?.pushNamed(
          Constants.chatScreen,
          arguments: data,
        );
        break;
      case 'profile':
        navigatorKey.currentState?.pushNamed(Constants.profileScreen);
        break;
      case 'friends':
        navigatorKey.currentState?.pushNamed(Constants.friendsScreen);
        break;
      default:
        debugPrint("⚠️ Unknown screen: $screen");
    }
  }

}
