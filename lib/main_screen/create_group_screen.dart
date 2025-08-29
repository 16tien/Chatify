import 'dart:io';

import 'package:chat_app/constants.dart';
import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:chat_app/widgets/display_user_image.dart';
import 'package:chat_app/widgets/friends_list.dart';
import 'package:chat_app/widgets/group_type_list_tile.dart';
import 'package:chat_app/widgets/my_app_bar.dart';
import 'package:chat_app/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  final TextEditingController groupDescriptionController =
      TextEditingController();
  File? finalFileImage;
  String userImage = '';

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Thư viện'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }

  GroupType groupValue = GroupType.private;

  void createGroup() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();
    if (groupNameController.text.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập tên nhóm');
      return;
    }

    if (groupNameController.text.length < 3) {
      showSnackBar(context, 'Tên nhóm ít nhất 3 kí tự');
      return;
    }

    if (groupDescriptionController.text.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập mô tả nhóm');
      return;
    }

    GroupModel groupModel = GroupModel(
      creatorUID: uid,
      groupName: groupNameController.text,
      groupDescription: groupDescriptionController.text,
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: groupValue == GroupType.private ? true : false,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoin: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );

    groupProvider.createGroup(
      newGroupModel: groupModel,
      fileImage: finalFileImage,
      onSuccess: () {
        showSnackBar(context, 'Tạo nhóm thành công');
        Navigator.pop(context);
      },
      onFail: (error) {
        showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Tạo nhóm'),
        onPressed: () => Navigator.pop(context),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: context.watch<GroupProvider>().isSloading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: () {
                        // create group
                        createGroup();
                      },
                      icon: const Icon(Icons.check)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DisplayUserImage(
                  finalFileImage: finalFileImage,
                  radius: 60,
                  onPressed: () {
                    showBottomSheet();
                  },
                ),
                const SizedBox(width: 10),
                buildGroupType(),
              ],
            ),
            const SizedBox(height: 10),

            // texField for group name
            TextField(
              controller: groupNameController,
              maxLength: 25,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Tên nhóm',
                label: Text('Tên nhóm'),
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: groupDescriptionController,
              maxLength: 100,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Mô tả nhóm',
                label: Text('Mô tả nhóm'),
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                ),
                child: SettingsListTile(
                    title: 'Cài đặt nhóm',
                    icon: Icons.settings,
                    iconContainerColor: Colors.deepPurple,
                    onTap: () {
                      Navigator.pushNamed(
                          context, Constants.groupSettingsScreen);
                    }),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chọn thành viên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Expanded(
              child: FriendsList(
                viewType: FriendViewType.groupView,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildGroupType() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.private.name,
            value: GroupType.private,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.public.name,
            value: GroupType.public,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}
