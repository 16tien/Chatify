import 'package:chat_app/constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main_screen/call_screen.dart';
import '../main_screen/calling_screen.dart';
import '../models/call_model.dart';
import '../providers/call_provider.dart';


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
                      ? 'Trực tuyến'
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
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () async {
                final authProvider = context.read<AuthenticationProvider>();
                final currentUserId = authProvider.uid!;
                final currentUserName = authProvider.userModel!.name;

                final receiverId = userModel.uid;
                final receiverName = userModel.name;
                final callId = '${currentUserId}$receiverId';

                final callModel = {
                  'callId': callId,
                  'callerId': currentUserId,
                  'callerName': currentUserName,
                  'receiverId': receiverId,
                  'receiverName': receiverName,
                  'status': 'ringing',
                  'timestamp': FieldValue.serverTimestamp(),
                };

                // 1. Lưu vào Firestore
                await FirebaseFirestore.instance
                    .collection('calls')
                    .doc(callId)
                    .set(callModel);
                await context.read<AuthenticationProvider>().sendCallRequest(receiverId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallingScreen(
                      callId: callId,
                      userId: currentUserId,
                      isCaller: true,
                      receiverName: receiverName,
                    ),
                  ),
                );
              },
            )

          ],
        );
      },
    );
  }
}
