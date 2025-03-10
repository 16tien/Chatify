import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/authentication/landing_screen.dart';
import 'package:chat_app/authentication/login_screen.dart';
import 'package:chat_app/authentication/register_screen.dart';
import 'package:chat_app/authentication/user_information_screen.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/main_screen/chat_screen.dart';
import 'package:chat_app/main_screen/friend_requests_screen.dart';
import 'package:chat_app/main_screen/friends_screen.dart';
import 'package:chat_app/main_screen/group_information_screen.dart';
import 'package:chat_app/main_screen/group_settings_screen.dart';
import 'package:chat_app/main_screen/home_screen.dart';
import 'package:chat_app/main_screen/incoming_call_screen.dart';
import 'package:chat_app/main_screen/profile_screen.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/push_notification/notification_services.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationServices.displayNotification(message);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Flutter Chat Pro',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.incomingCallScreen: (context) => const IncomingCallScreen(),
          Constants.registerScreen: (context) => const RegisterScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          // Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) =>
              const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.groupSettingsScreen: (context) =>
              const GroupSettingsScreen(),
          Constants.groupInformationScreen: (context) =>
              const GroupInformationScreen(),
        },
      ),
    );
  }
}
