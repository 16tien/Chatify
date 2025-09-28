import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/features/authentication/presentation/screens/landing_screen.dart';
import 'package:chat_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:chat_app/features/authentication/presentation/screens/register_screen.dart';
import 'package:chat_app/features/authentication/presentation/screens/user_information_screen.dart';
import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/friends/presentation/screens/friend_requests_screen.dart';
import 'package:chat_app/features/friends/presentation/screens/friends_screen.dart';
import 'package:chat_app/features/groups/presentation/screens/group_information_screen.dart';
import 'package:chat_app/features/groups/presentation/screens/group_settings_screen.dart';
import 'package:chat_app/features/profile/presentation/screens/home_screen.dart';
import 'package:chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/features/chat/presentation/viewmodels/chat_provider.dart';
import 'package:chat_app/features/groups/presentation/viewmodels/group_provider.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/firebase_options.dart';
import 'core/utils/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

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
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.registerScreen: (context) => const RegisterScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
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
