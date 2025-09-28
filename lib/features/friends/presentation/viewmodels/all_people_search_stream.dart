import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/authentication/data/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/enums/enums.dart';
import '../widget/friend_widget.dart';

class AllPeopleSearchStream extends StatelessWidget {
  const AllPeopleSearchStream({
    super.key,
    required this.uid,
    required this.searchText,
  });

  final String uid;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    // stream the last message collection
    final stream =
        FirebaseFirestore.instance.collection(Constants.users).snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (builderContext, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final results = snapshot.data!.docs
              .where((element) => element[Constants.name]
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
              .toList();

          if (results.isEmpty) {
            return const Center(
              child: Text('Không tìm thấy'),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final doc = results.elementAt(index);
                final data = doc.data() as Map<String, dynamic>;
                final item = UserModel.fromMap(data);
                if (item.uid == uid) {
                  return Container(); // skip the current user from the list
                }
                return FriendWidget(
                  friend: item,
                  viewType: FriendViewType.allUsers,
                );
              },
            );
          }
          return const Center(
            child: Text('No user found'),
          );
        });
  }
}
