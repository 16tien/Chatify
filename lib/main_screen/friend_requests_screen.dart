import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/widgets/my_app_bar.dart';
import 'package:chat_app/widgets/friends_list.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key, this.groupId = ''});

  final String groupId;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Requests'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
              },
            ),

            Expanded(
                child: FriendsList(
                  viewType: FriendViewType.friendRequests,
                  groupId: widget.groupId,
                )),
          ],
        ),
      ),
    );
  }
}