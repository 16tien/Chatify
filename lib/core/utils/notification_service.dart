import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'global_methods.dart';
import '../constants/constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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
    });

    // App killed → mở bằng notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateToScreen(
        initialMessage.data['screen'] ?? '',
        initialMessage.data,
      );
    }
  }

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

  // Handle FCM in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
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
      payload: jsonEncode(data),
    );
  }


  // Navigate based on screen key
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
  Future<void> sendPushNotification(
      String friendID, String title, String body) async {
    String bearerToken =
    await getBearerToken();
    String? token = await getTokenByUID(friendID);
    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "android": {
          "priority": "HIGH",
          "notification": {
            "channel_id": "chat_channel",
            "sound": "custom_sound",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        },
        "data": {
          "screen": "chat",
        }
      }
    };

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/flutterchat-e84e9/messages:send'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  }
  Future<String> getBearerToken() async {

    String jsonString = await rootBundle.loadString(
        'assets/flutterchat-e84e9-firebase-adminsdk-8rkwu-a86c582c6e.json');
    Map<String, dynamic> credentialsJson = jsonDecode(jsonString);

    var credentials = ServiceAccountCredentials.fromJson(credentialsJson);

    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    var client = await clientViaServiceAccount(credentials, scopes);
    return client.credentials.accessToken.data;
  }

  Future<String?> getTokenByUID(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(Constants.users)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        String token = userDoc[Constants.token];
        return token;
      } else {
        print("User not found!");
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

}
