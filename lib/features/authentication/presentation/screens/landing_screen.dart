import 'dart:developer';

import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/core/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      bool isAuthenticated = await authProvider.checkAuthenticationState();

      if (mounted) {
        navigate(isAuthenticated: isAuthenticated);
      }
    } catch (e) {
      log('Lỗi khi kiểm tra xác thực: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, Constants.loginScreen);
      }
    }
  }

  void navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AssetsManager.chatBubble),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
