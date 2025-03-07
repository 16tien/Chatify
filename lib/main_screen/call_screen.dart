import 'package:chat_app/constants.dart';
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
        appID: Constants.appId,
        // Thay bằng AppID của bạn từ ZegoCloud
        appSign:Constants.appSign,
        callID: '$callID$userID',
        userID: userID,
        userName: userName,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
