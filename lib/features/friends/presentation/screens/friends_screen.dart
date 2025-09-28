import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/enums/enums.dart';
import '../widget/friends_list.dart';
import '../../../../core/widgets/my_app_bar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Bạn bè'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Tìm kiếm',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
              },
              onSuffixTap: () {
                if (kDebugMode) {
                  print('suffix tap');
                }
                FocusScope.of(context).unfocus();
              },
            ),

            Expanded(
                child: FriendsList(
              viewType: FriendViewType.friends,
            )),
          ],
        ),
      ),
    );
  }
}
