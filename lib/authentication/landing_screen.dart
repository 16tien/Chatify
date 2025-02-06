import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/utilities/assets_manager.dart';
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
    checkAthentication();
    super.initState();
  }

  void checkAthentication() async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      bool isAuthenticated = await authProvider.checkAuthenticationState();

      // Điều hướng sau khi xác định trạng thái xác thực
      navigate(isAuthenticated: isAuthenticated);
    } catch (e) {
      log('Lỗi khi kiểm tra xác thực: $e');
      // Có thể điều hướng đến màn hình đăng nhập nếu gặp lỗi
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
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
        child: SizedBox(
          height: 400,
          width: 200,
          child: Column(
            children: [
              Lottie.asset(AssetsManager.chatBubble),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}