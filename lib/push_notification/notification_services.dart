import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/push_notification/navigation_controller.dart';
import 'package:chat_app/push_notification/notification_channels.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannelAndInitialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
          NotificationChannels.highInportanceChannel);
      await androidImplementation
          .createNotificationChannel(NotificationChannels.lowInportanceChannel);
    }
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationRespons) {
    log('onDidReceiveNotificationResponse : $notificationRespons');
    final payload = notificationRespons.payload;
    if (payload != null) {
      // convert payload to remoteMessage and handle interaction
      final message = RemoteMessage.fromMap(jsonDecode(payload));
      log('message: $message');
      navigationController(
          context: navigatorKey.currentState!.context, message: message);
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationRespons) {
    log('BackgroundPayload : $notificationRespons');
  }

  static displayNotification(RemoteMessage message) {
    log('display notification: $message');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;

    String channelId = android?.channelId ?? 'default_channel';

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, // Channel id.
          findChannelName(channelId), // Channel name.
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: android?.smallIcon, // Optional icon to use.
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  static String findChannelName(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return NotificationChannels.highInportanceChannel.name;
      case 'low_importance_channel':
        return NotificationChannels.lowInportanceChannel.name;
      default:
        return NotificationChannels.highInportanceChannel.name;
    }
  }
}
