import 'package:chat_app/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/botton_chat_field.dart';
import '../../../../core/widgets/chat_app_bar.dart';
import '../../../../core/widgets/chat_list.dart';
import '../../../../core/widgets/group_chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImage = arguments[Constants.contactImage];
    final groupId = arguments[Constants.groupId];
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor,
        title: isGroupChat
            ? GroupChatAppBar(groupId: groupId)
            : ChatAppBar(contactUID: contactUID),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                contactUID: contactUID,
                groupId: groupId,
              ),
            ),
            BottomChatField(
              contactUID: contactUID,
              contactName: contactName,
              contactImage: contactImage,
              groupId: groupId,
            ),
          ],
        ),
      ),
    );
  }
}
