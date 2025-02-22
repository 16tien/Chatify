import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String userID;
  final String userName;
  final String calleeID;

  const CallScreen({
    super.key,
    required this.userID,
    required this.userName,
    required this.calleeID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zego Call")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // ZegoUIKitPrebuiltCallInvitationService().sendCallInvitation(
            //   inviterID: userID,
            //   inviterName: userName,
            //   invitees: [calleeID], // ID của B
            //   callType: ZegoCallType.videoCall,
            // );
          },
          child: const Text("Gọi Video"),
        ),
      ),
    );
  }
}
