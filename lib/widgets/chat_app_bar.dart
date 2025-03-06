import 'package:chat_app/constants.dart';
import 'package:chat_app/main_screen/call_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({super.key, required this.contactUID});

  final String contactUID;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context
          .read<AuthenticationProvider>()
          .userStream(userID: widget.contactUID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userModel =
            UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        DateTime lastSeen =
            DateTime.fromMillisecondsSinceEpoch(int.parse(userModel.lastSeen));

        return Row(
          children: [
            userImageWidget(
              imageUrl: userModel.image,
              radius: 20,
              onTap: () {
                // Chuyển đến màn hình hồ sơ của bạn bè với UID làm tham số
                Navigator.pushNamed(
                  context,
                  Constants.profileScreen,
                  arguments: userModel.uid,
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                Text(
                  userModel.isOnline
                      ? 'Online'
                      : 'Last seen ${timeago.format(lastSeen)}',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: userModel.isOnline
                        ? Colors.green
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Nút gọi điện
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () async {
                final authProvider = context.read<AuthenticationProvider>();
                final String? callerID = authProvider.uid; // ID của người gọi
                final String name = authProvider.userModel!.name;
                final String receiverID = userModel.uid; // ID người nhận
                final String callID =
                    "$callerID$receiverID"; // Mã phòng duy nhất
                authProvider.sendCallRequest(receiverID);
                // Lưu thông tin cuộc gọi lên Firestore
                FirebaseFirestore.instance.collection('calls').doc(callID).set({
                  'callerID': callerID,
                  'receiverID': receiverID,
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'ringing', // Trạng thái cuộc gọi đang đổ chuông
                });

                // Điều hướng đến màn hình chờ cuộc gọi
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                        callID: callerID! + receiverID,
                        userID: callID,
                        userName: name),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
