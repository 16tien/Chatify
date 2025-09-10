import 'package:chat_app/core/widgets/settings_list_tile.dart';
import 'package:chat_app/features/groups/presentation/screens/group_settings_screen.dart';
import 'package:chat_app/features/groups/presentation/viewmodels/group_provider.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:flutter/material.dart';

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(
              title: "Cài đặt nhóm",
              icon: Icons.settings,
              iconContainerColor: Colors.deepPurple,
              onTap: () {
                if (!isAdmin) {
                  // show snackbar
                  showSnackBar(context, 'Chỉ quản trị mới có thể thay đổi');
                } else {
                  groupProvider.updateGroupAdminsList().whenComplete(() {
                    // navigate to group settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupSettingsScreen(),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
