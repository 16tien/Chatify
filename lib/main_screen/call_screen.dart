import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;

  const CallScreen(
      {super.key,
      required this.callID,
      required this.userID,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1966915086,
        // Thay bằng AppID của bạn từ ZegoCloud
        appSign:
            'f2b84d4461357142a31adb0ba14084324ebaa9d445f18994d20b4f338730a5ac',
        callID: '$callID$userID',
        userID: userID,
        userName: userName,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
