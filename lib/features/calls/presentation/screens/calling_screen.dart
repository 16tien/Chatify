import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'call_screen.dart';

class CallingScreen extends StatelessWidget {
  final String callId;
  final String receiverName;
  final bool isCaller;
  final String userId;
  const CallingScreen({
    super.key,
    required this.callId,
    required this.receiverName,
    required this.isCaller,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final callData = snapshot.data!.data() as Map<String, dynamic>;
        final status = callData['status'] ?? '';

        if (status == 'cancelled') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Người nhận từ chối cuộc gọi')),
            );
          });
        }


        if (status == 'accepted') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(
                  callID: callId,
                  userID: userId,
                  userName: receiverName,
                ),
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: Colors.black87,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  status == 'accepted'
                      ? 'Kết nối với $receiverName...'
                      : 'Đang gọi $receiverName...',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'cancelled'});
                    Navigator.pop(context);
                  },
                  child: const Text('Hủy'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
