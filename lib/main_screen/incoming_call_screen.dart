import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../utilities/global_methods.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  String callerName = "Đang tải...";
  String callerImage = "";
  late String callID;

  @override
  void initState() {
    super.initState();
    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    String currentId = context.read<AuthenticationProvider>().userModel!.uid;

    FirebaseFirestore.instance
        .collection('calls')
        .where('receiverID', isEqualTo: currentId)
        .where('status',
            isEqualTo: 'ringing') // Chỉ lấy cuộc gọi đang đổ chuông
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var callData = snapshot.docs.first.data();
        String callerID = callData['callerID'] ?? ''; // Lấy ID của người gọi

        if (callerID.isNotEmpty) {
          // Lấy thông tin người gọi từ collection 'users'
          FirebaseFirestore.instance
              .collection('users')
              .doc(callerID)
              .get()
              .then((userDoc) {
            if (userDoc.exists) {
              var userData = userDoc.data();

              if (!mounted)return; // Kiểm tra widget còn tồn tại trước khi cập nhật state

              setState(() {
                callID = callData['callerID'] + callData['receiverID'];
                callerName = userData?['name'] ??
                    'Người gọi không xác định'; // Tên người gọi
                callerImage = userData?['image'] ?? ''; // Ảnh người gọi
              });
            }
          });
        }
      }
    });
  }

  void _acceptCall() async {
    await FirebaseFirestore.instance.collection('calls').doc(callID).update({
      'status': 'accepted',
    });
    String currentId = context.read<AuthenticationProvider>().userModel!.uid;
    String userName =  context.read<AuthenticationProvider>().userModel!.name;
    // Điều hướng đến màn hình gọi video (CallScreen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callID: callID,
          userID: currentId,
          userName: userName,
        ),
      ),
    );
  }

  void _declineCall() async {
    await FirebaseFirestore.instance.collection('calls').doc(callID).update({
      'status': 'declined',
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
                getImageToShow(imageUrl: callerImage, fileImage: null),
          ),
          const SizedBox(height: 16),
          Text(
            "Cuộc gọi từ: $callerName",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _declineCall,
                backgroundColor: Colors.red,
                heroTag: "declineCall",
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
              const SizedBox(width: 40),
              FloatingActionButton(
                onPressed: _acceptCall,
                backgroundColor: Colors.green,
                heroTag: "acceptCall",
                child: const Icon(Icons.call, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
