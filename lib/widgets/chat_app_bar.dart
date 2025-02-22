import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main_screen/call_screen.dart';

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
                // Navigate to this friend's profile with UID as argument
                Navigator.pushNamed(context, Constants.profileScreen,
                    arguments: userModel.uid);
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                  ),
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
            // Thêm nút gọi ở đây
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                // Xử lý gọi điện khi nhấn nút
                _startCall(userModel);
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm để xử lý cuộc gọi
  void _startCall(UserModel user) {
    final String currentUserId = context.read<AuthenticationProvider>().uid.toString();
    final String callId = "${currentUserId}_${user.uid}"; // Tạo mã phòng duy nhất


  }


// Ví dụ: Dùng `url_launcher` để gọi điện
// Future<void> _makePhoneCall(String phoneNumber) async {
//   final Uri launchUri = Uri(
//     scheme: 'tel',
//     path: phoneNumber,
//   );
//   await launch(launchUri.toString());
// }
}
