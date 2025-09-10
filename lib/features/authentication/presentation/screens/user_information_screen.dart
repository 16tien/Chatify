import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/authentication/data/user_model.dart';
import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/display_user_image.dart';
import '../../../../core/widgets/my_app_bar.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authentication =
        context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Thông tin cá nhân'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            DisplayUserImage(
              finalFileImage: authentication.finalFileImage,
              radius: 60,
              onPressed: () {
                authentication.showBottomSheet(
                    context: context, onSuccess: () {});
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Nhập tên của bạn',
                labelText: 'Nhập tên của bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: context.read<AuthenticationProvider>().isLoading
                    ? null
                    : () {
                        if (_nameController.text.isEmpty ||
                            _nameController.text.length < 3) {
                          showSnackBar(context, 'Vui lòng nhập tên của bạn');
                          return;
                        }
                        // save user data to firestore
                        saveUserDataToFireStore();
                      },
                child: context.watch<AuthenticationProvider>().isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      )
                    : const Text(
                        'Tiếp tục',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5),
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      email: authProvider.email!,
      image: '',
      token: '',
      aboutMe: 'Xin chào',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      onSuccess: () async {
        await authProvider.saveUserDataToSharedPreferences();
        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}
