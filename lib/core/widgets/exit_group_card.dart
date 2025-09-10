import 'package:chat_app/core/widgets/settings_list_tile.dart';
import 'package:chat_app/features/groups/presentation/viewmodels/group_provider.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExitGroupCard extends StatelessWidget {
  const ExitGroupCard({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
          title: 'Rời nhóm',
          icon: Icons.exit_to_app,
          iconContainerColor: Colors.red,
          onTap: () {
            // exit group
            showMyAnimatedDialog(
              context: context,
              title: 'Rời nhóm',
              content: 'Bạn có chắc muốn rời nhóm?',
              textAction: 'Rời nhóm',
              onActionTap: (value, updatedText) async {
                if (value) {
                  // exit group
                  final groupProvider = context.read<GroupProvider>();
                  await groupProvider.exitGroup(uid: uid).whenComplete(() {
                    showSnackBar(context, 'Bạn đã thoát nhóm');
                    // navigate to first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}
