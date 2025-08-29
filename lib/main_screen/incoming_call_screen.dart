import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;

  const IncomingCallScreen({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Không có dữ liệu cuộc gọi")),
          );
        }

        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Cuộc gọi không tồn tại hoặc đã kết thúc")),
          );
        }


        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text("Dữ liệu cuộc gọi trống")),
          );
        }

        final status = data['status'] ?? '';
        final callerName = data['callerName'] ?? 'Người gọi';
        final userId = data['receiverId'] ?? '';

        // 🔹 Nếu người gọi hủy
        if (status == 'cancelled' || status == 'ended') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(
            body: Center(child: Text("Cuộc gọi đã kết thúc")),
          );
        }

        // 🔹 Nếu đã accept thì chuyển sang CallScreen
        if (status == 'accepted') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(
                  callID: callId,
                  userID: userId,
                  userName: callerName,
                ),
              ),
            );
          });
          return const Scaffold(
            body: Center(child: Text("Đang kết nối...")),
          );
        }

        if (status == 'ringing') {
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  Text(
                    'Cuộc gọi từ $callerName...',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('calls')
                              .doc(callId)
                              .update({'status': 'accepted'});
                        },
                        child: const Text('Chấp nhận'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('calls')
                              .doc(callId)
                              .update({'status': 'cancelled'});
                        },
                        child: const Text('Từ chối'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Đang xử lý cuộc gọi...")),
        );
      },
    );
  }
}
