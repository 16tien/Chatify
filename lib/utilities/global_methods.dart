import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/utilities/assets_manager.dart';
import 'package:chat_app/widgets/friends_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void showSnackBar(BuildContext context, String message) {
  if (ScaffoldMessenger.of(context).mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}


Widget userImageWidget({
  required String imageUrl,
  File? fileImage,
  required double radius,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: getImageToShow(
          imageUrl: imageUrl,
          fileImage: fileImage,
        )),
  );
}

getImageToShow({
  required String imageUrl,
  required File? fileImage,
}) {
  return fileImage != null
      ? FileImage(File(fileImage.path)) as ImageProvider
      : imageUrl.isNotEmpty
      ? CachedNetworkImageProvider(imageUrl)
      : const AssetImage(AssetsManager.userImage);
}

// picp image from gallery or camera
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    // get picture from camera
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    // get picture from gallery
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}

// pick video from gallery
Future<File?> pickVideo({
  required Function(String) onFail,
}) async {
  File? fileVideo;
  try {
    final pickedFile =
    await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      onFail('No video selected');
    } else {
      fileVideo = File(pickedFile.path);
    }
  } catch (e) {
    onFail(e.toString());
  }

  return fileVideo;
}

Center buildDateTime(groupedByValue) {
  return Center(
    child: Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          formatDate(groupedByValue.timeSent, [dd, ' ', M, ', ', yyyy]),
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget messageToShow({required MessageEnum type, required String message}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    case MessageEnum.image:
      return const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 10),
          Text(
            'Image',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.video:
      return const Row(
        children: [
          Icon(Icons.video_library_outlined),
          SizedBox(width: 10),
          Text(
            'Video',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.audio:
      return const Row(
        children: [
          Icon(Icons.audiotrack_outlined),
          SizedBox(width: 10),
          Text(
            'Audio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    default:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
  }
}

//luu anh
Future<String> storeFileToCloudinary({
  required File file,
  required String reference, // Giữ lại tham số 'reference' như yêu cầu
}) async {
  try {
    const String cloudName = 'dzpnecose';

    // Kiểm tra loại tệp (image/video) dựa trên phần mở rộng
    String fileExtension = file.path.split('.').last.toLowerCase();
    String resourceType = (fileExtension == 'mp4' || fileExtension == 'mov' || fileExtension == 'avi' || fileExtension == 'webm')
        ? 'video' // Nếu là video
        : 'image'; // Nếu là hình ảnh

    // URL API của Cloudinary
    final Uri uploadUrl =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    // Chuẩn bị request multipart để upload
    var request = http.MultipartRequest('POST', uploadUrl);

    // Các thông tin cần thiết
    request.fields['upload_preset'] = 'ml_default';
    request.fields['folder'] = 'user_files'; // Thư mục lưu trữ (có thể thay đổi)

    // Thêm tệp vào request
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: reference,
    ));

    // Gửi request
    var response = await request.send();

    // Xử lý phản hồi
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      // Trả về URL của tệp đã tải lên
      return data['secure_url'];
    } else {
      throw Exception('Failed to upload file: ${response.reasonPhrase}');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Error uploading to Cloudinary: $e');
  }
}


// animated dialog
void showMyAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String textAction,
  required Function(bool, String) onActionTap,
  bool editable = false,
  String hintText = '',
}) {
  TextEditingController controller = TextEditingController(text: hintText);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: editable
                  ? TextField(
                controller: controller,
                maxLength: content == Constants.changeName ? 20 : 500,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintText,
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
                  : Text(
                content,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      false,
                      controller.text,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      true,
                      controller.text,
                    );
                  },
                  child: Text(textAction),
                ),
              ],
            ),
          ));
    },
  );
}

// show bottom sheet with the list of all app users to add them to the group
void showAddMembersBottomSheet({
  required BuildContext context,
  required List<String> groupMembersUIDs,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return PopScope(
        onPopInvoked: (bool didPop) async {
          if (!didPop) return;
          // do something when the bottom sheet is closed.
          await context.read<GroupProvider>().removeTempLists(isAdmins: false);
        },
        child: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CupertinoSearchTextField(
                        onChanged: (value) {
                          // search for users
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<GroupProvider>()
                            .updateGroupDataInFireStoreIfNeeded()
                            .whenComplete(() {
                          // close bottom sheet
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              Expanded(
                child: FriendsList(
                  viewType: FriendViewType.groupView,
                  groupMembersUIDs: groupMembersUIDs,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}