import 'package:chat_app/constants.dart';
import 'package:chat_app/main_screen/create_group_screen.dart';
import 'package:chat_app/main_screen/groups_screen.dart';
import 'package:chat_app/main_screen/my_chats_screen.dart';
import 'package:chat_app/main_screen/people_screen.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/push_notification/notification_services.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  void initState() {
    checkPermissions();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthenticationProvider>().generateNewToken();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data['type'] == 'call') {
          String callerUid = message.data['callerId'];
          showCallWaitingScreen(callerUid);
        } else {
          NotificationServices.displayNotification(message);
        }
      });
    });
  }

// show incoming screen
  void showCallWaitingScreen(String callerUid) {
    Navigator.pushNamed(context, Constants.incomingCallScreen,
        arguments: callerUid);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
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

  Future<bool> checkPermissions() async {
    // Yêu cầu quyền Camera và Microphone
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
