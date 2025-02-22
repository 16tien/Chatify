
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/main_screen/create_group_screen.dart';
import 'package:chat_app/main_screen/my_chats_screen.dart';
import 'package:chat_app/main_screen/groups_screen.dart';
import 'package:chat_app/main_screen/people_screen.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/push_notification/navigation_controller.dart';
import 'package:chat_app/push_notification/notification_services.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool _appBadgeSupported = false;

  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    requestNotificationPermissions();
    NotificationServices.createNotificationChannelAndInitialize();
    initCloudMessaging();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  // request notification permissions
  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    }

    NotificationSettings notificationSettings =
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
  void initCloudMessaging() async {
    // make sure widget is initialized before initializing cloud messaging
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. generate a new token
      await context.read<AuthenticationProvider>().generateNewToken();

      // 2. initialize firebase messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a new message: ${message.messageId}');
        print('Data: ${message.data}');

        // Kiểm tra loại thông báo
        if (message.data['type'] == 'call') {
          // Thông báo kiểu cuộc gọi
          print('Call notification received');

          // Log thông báo chờ
          print('Waiting for user response for 30 seconds...');

          // Hiển thị màn hình chờ cho cuộc gọi
          showCallWaitingScreen();

          // Chờ 30 giây
          Future.delayed(Duration(seconds: 30), () {
            // Kiểm tra xem người dùng có phản hồi không sau 30s
            // Nếu không phản hồi, hủy cuộc gọi
            print('Call timeout after 30 seconds');
            cancelCall();
          });

        } else {
          // Thông báo kiểu tin nhắn
          print('Message notification received');

          // Hiển thị thông báo đẩy
          NotificationServices.displayNotification(message);
          // Setup background message handler
          FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

          // 3. setup onMessage handler for interactions
          setupInteractedMessage();
        }
      });


    });
  }

// Hiển thị màn hình chờ cuộc gọi
  void showCallWaitingScreen() {
    // Bạn có thể mở một màn hình chờ cho người dùng ở đây

  }

// Hủy cuộc gọi sau 30 giây nếu không có phản hồi
  void cancelCall() {
    // Xử lý logic hủy cuộc gọi ở đây
    print("Call has been canceled due to timeout.");
    Navigator.pop(context);
  }

// Background message handler function
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Xử lý trong background tại đây (cập nhật UI, thông báo...)
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    navigationController(context: context, message: message);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // user comes back to the app
      // update user status to online
        context.read<AuthenticationProvider>().updateUserStatus(
          value: true,
        );
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      // app is inactive, paused, detached or hidden
      // update user status to offline
        context.read<AuthenticationProvider>().updateUserStatus(
          value: false,
        );
        break;
      default:
      // handle other states
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('CHATFITY'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: userImageWidget(
                imageUrl: authProvider.userModel!.image,
                radius: 20,
                onTap: () {
                  // navigate to user profile with uis as arguments
                  Navigator.pushNamed(
                    context,
                    Constants.profileScreen,
                    arguments: authProvider.userModel!.uid,
                  );
                },
              ),
            )
          ],
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: pages,
        ),
        floatingActionButton: currentIndex == 1
            ? FloatingActionButton(
          onPressed: () {
            context
                .read<GroupProvider>()
                .clearGroupMembersList()
                .whenComplete(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen(),
                ),
              );
            });
          },
          child: const Icon(CupertinoIcons.add),
        )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              label: 'Trò chuyện',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group),
              label: 'Nhóm',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe),
              label: 'Mọi người',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) {
            // animate to the page
            pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
            setState(() {
              currentIndex = index;
            });
          },
        ));
  }
}