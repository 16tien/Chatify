import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/authentication/data/user_model.dart';
import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/info_details_card.dart';
import '../../../../core/widgets/my_app_bar.dart';
import '../../../../core/widgets/settings_list_tile.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = context.watch<AuthenticationProvider>();
    bool isMyProfile = uid == authProvider.uid;
    return authProvider.isLoading
        ? const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text('Đang lưu ảnh, vui lòng đợi....')
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: MyAppBar(
        title: const Text('Hồ sơ'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: StreamBuilder(
        stream: context
            .read<AuthenticationProvider>()
            .userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDetailsCard(
                    userModel: userModel,
                  ),
                  const SizedBox(height: 10),
                  isMyProfile
                      ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Cài đặt',
                          style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: 'Tài khoản',
                              icon: Icons.person,
                              iconContainerColor: Colors.deepPurple,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),

                            SettingsListTile(
                              title: 'Thông báo',
                              icon: Icons.notifications,
                              iconContainerColor: Colors.red,
                              onTap: () {
                                  authProvider.sendPushNotification('4liYyFoekSeStSL51neHcF8SPJA3', "hellooo", "xin chao");
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: 'Giúp đỡ',
                              icon: Icons.help,
                              iconContainerColor: Colors.yellow,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                            SettingsListTile(
                              title: 'Chia sẽ',
                              icon: Icons.share,
                              iconContainerColor: Colors.blue,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                            // added padding for the list tile
                            left: 8.0,
                            right: 8.0,
                          ),
                          leading: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                isDarkMode
                                    ? Icons.nightlight_round
                                    : Icons.wb_sunny_rounded,
                                color: isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                          title: const Text('Sáng/tối'),
                          trailing: Switch(
                              value: isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  isDarkMode = value;
                                }); // check if the value is true
                                if (value) {
                                  AdaptiveTheme.of(context)
                                      .setDark();
                                } else {
                                  AdaptiveTheme.of(context)
                                      .setLight();
                                }
                              }),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: 'Đăng xuất',
                              icon: Icons.logout_outlined,
                              iconContainerColor: Colors.red,
                              onTap: () {
                                showMyAnimatedDialog(
                                  context: context,
                                  title: 'Đăng xuất',
                                  content: 'Bạn có chắc muốn đăng xuất không?',
                                  textAction: 'Đăng xuất',
                                  onActionTap: (value, updatedText) async {
                                    if (value) {
                                      // logout
                                      await context.read<AuthenticationProvider>().logout();
                                      // Đảm bảo rằng Navigator chỉ được gọi khi context còn hợp lệ
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          Constants.loginScreen,
                                              (route) => false,
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}