import 'dart:io';
import 'package:chat_app/features/authentication/data/user_model.dart';
import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/features/groups/presentation/viewmodels/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/enums.dart';
import '../../../friends/presentation/widget/friend_widget.dart';
import '../widget/settings_list_tile.dart';
import '../../../chat/presentation/widget/settings_switch_list_tile.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  String getGroupAdminsNames({
    required GroupProvider groupProvider,
    required String uid,
  }) {
    if (groupProvider.groupMembersList.isEmpty) {
      return 'Để gán vai trò quản trị viên, vui lòng thêm thành viên nhóm vào màn hình trước';
    } else {
      List<String> groupAdminsNames = [];

      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      List<String> groupAdminsNamesList = groupAdminsList.map((groupAdmin) {
        return groupAdmin.uid == uid ? 'Bạn' : groupAdmin.name;
      }).toList();

      groupAdminsNames.addAll(groupAdminsNamesList);

      return groupAdminsNames.length == 2
          ? '${groupAdminsNames[0]} và ${groupAdminsNames[1]}'
          : groupAdminsNames.length > 2
              ? '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} và ${groupAdminsNames.last}'
              : 'Bạn';
    }
  }

  Color getAdminsContainerColor({
    required GroupProvider groupProvider,
  }) {
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor;
    } else {
      return Theme.of(context).cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Cài đặt nhóm'),
          leading: IconButton(
            onPressed: () {
              context
                  .read<GroupProvider>()
                  .removeTempLists(isAdmins: true)
                  .whenComplete(() {
                Navigator.pop(context);
              });
            },
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Consumer<GroupProvider>(
            builder: (context, groupProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                child: Column(
                  children: [
                    SettingsSwitchListTile(
                      title: 'Chỉnh sửa nhóm',
                      subtitle:
                          'Chỉ có quản trị viên mới có thể thay đổi thông tin nhóm, tên, hình ảnh và mô tả',
                      icon: Icons.edit,
                      containerColor: Colors.green,
                      value: groupProvider.groupModel.editSettings,
                      onChanged: (value) {
                        groupProvider.setEditSettings(value: value);
                      },
                    ),
                    const SizedBox(height: 10),
                    SettingsSwitchListTile(
                      title: 'Phê duyệt thành viên mới',
                      subtitle:
                          'Thành viên mới sẽ chỉ được thêm vào sau khi được quản trị viên chấp thuận',
                      icon: Icons.approval,
                      containerColor: Colors.blue,
                      value: groupProvider.groupModel.approveMembers,
                      onChanged: (value) {
                        groupProvider.setApproveNewMembers(value: value);
                      },
                    ),
                    const SizedBox(height: 10),
                    groupProvider.groupModel.approveMembers
                        ? SettingsSwitchListTile(
                            title: 'Yêu cầu tham gia',
                            subtitle:
                                'Yêu cầu thành viên mới tham gia nhóm trước khi xem nội dung nhóm',
                            icon: Icons.request_page,
                            containerColor: Colors.orange,
                            value: groupProvider.groupModel.requestToJoin,
                            onChanged: (value) {
                              groupProvider.setRequestToJoin(value: value);
                            },
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    SettingsSwitchListTile(
                      title: 'Khóa tin nhắn',
                      subtitle:
                          'Chỉ có Quản trị viên mới có thể gửi tin nhắn, các thành viên khác chỉ có thể đọc tin nhắn',
                      icon: Icons.lock,
                      containerColor: Colors.deepPurple,
                      value: groupProvider.groupModel.lockMessages,
                      onChanged: (value) {
                        groupProvider.setLockMessages(value: value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color:
                          getAdminsContainerColor(groupProvider: groupProvider),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SettingsListTile(
                            title: 'Quản trị viên nhóm',
                            subtitle: getGroupAdminsNames(
                                groupProvider: groupProvider, uid: uid),
                            icon: Icons.admin_panel_settings,
                            iconContainerColor: Colors.red,
                            onTap: () {
                              if (groupProvider.groupMembersList.isEmpty) {
                                return;
                              }
                              groupProvider.setEmptyTemps();
                              showBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Chọn Quản trị viên nhóm',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    groupProvider
                                                        .updateGroupDataInFireStoreIfNeeded()
                                                        .whenComplete(() {
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Xong',
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: groupProvider
                                                    .groupMembersList.length,
                                                itemBuilder: (context, index) {
                                                  final friend = groupProvider
                                                      .groupMembersList[index];
                                                  return FriendWidget(
                                                    friend: friend,
                                                    viewType: FriendViewType
                                                        .groupView,
                                                    isAdminView: true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }
}
