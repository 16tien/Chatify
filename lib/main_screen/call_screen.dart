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
    print("Joining callID: $callID, userID: $userID");
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1104927737,
        appSign:
        '2fb74b60fdd6358dba1d7ca22bdf1658ad0c2e50c3b42c5b1cdfbbebeda04939',
        callID: callID,
        userID: userID,
        userName: userName,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}