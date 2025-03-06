import 'dart:async';

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
  String callID = "";
  StreamSubscription? _callSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForIncomingCalls();
    });
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  void _listenForIncomingCalls() {
    final currentId = context.read<AuthenticationProvider>().userModel?.uid;

    if (currentId == null) return;

    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverID', isEqualTo: currentId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var callData = snapshot.docs.first.data();
        String callerID = callData['callerID'] ?? '';

        if (callerID.isNotEmpty) {
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(callerID)
              .get();

          if (userDoc.exists) {
            var userData = userDoc.data();

            if (!mounted) return; // Kiểm tra widget còn tồn tại trước khi cập nhật state

            setState(() {
              callID = "${callData['callerID']}_${callData['receiverID']}";
              callerName = userData?['name'] ?? 'Người gọi không xác định';
              callerImage = userData?['image'] ?? '';
            });
          }
        }
      } else {
        if (!mounted) return;
        setState(() {
          callerName = "Không có cuộc gọi";
          callerImage = "";
          callID = "";
        });
      }
    });
  }

  void _acceptCall() async {
    if (callID.isEmpty) return;

    await FirebaseFirestore.instance.collection('calls').doc(callID).update({
      'status': 'accepted',
    });

    final currentUser = context.read<AuthenticationProvider>().userModel;
    if (currentUser == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callID: callID,
          userID: currentUser.uid,
          userName: currentUser.name,
        ),
      ),
    );
  }

  void _declineCall() async {
    if (callID.isEmpty) return;

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
            style: const TextStyle(
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
