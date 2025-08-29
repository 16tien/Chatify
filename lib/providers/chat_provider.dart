import 'dart:io';

import 'package:chat_app/constants.dart';
import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/models/last_message_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/message_reply_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var messageId = const Uuid().v4();
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'Bạn'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      if (groupId.isNotEmpty) {
        await _firestore
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.messages)
            .doc(messageId)
            .set(messageModel.toMap());
        await _firestore.collection(Constants.groups).doc(groupId).update({
          Constants.lastMessage: message,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(false);
        onSucess();
        setMessageReplyModel(null);
      } else {
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );

        setMessageReplyModel(null);
      }
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupId,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      var messageId = const Uuid().v4();

      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'Bạn'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageId';
      String fileUrl = await storeFileToCloudinary(file: file, reference: ref);

      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      if (groupId.isNotEmpty) {
        // handle group message
        // handle group message
        await _firestore
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.messages)
            .doc(messageId)
            .set(messageModel.toMap());

        await _firestore.collection(Constants.groups).doc(groupId).update({
          Constants.lastMessage: fileUrl,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(false);
        onSucess();
        setMessageReplyModel(null);
      } else {
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );
        setMessageReplyModel(null);
      }
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSucess,
    required Function(String p1) onError,
  }) async {
    try {
      final contactMessageModel = messageModel.copyWith(
        userId: messageModel.senderUID,
      );

      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(contactMessageModel.toMap());


      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .set(senderLastMessage.toMap());


      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .set(contactLastMessage.toMap());


      setLoading(false);
      onSucess();
    } on FirebaseException catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

  // send reaction to message
  Future<void> sendReactionToMessage({
    required String senderUID,
    required String contactUID,
    required String messageId,
    required String reaction,
    required bool groupId,
  }) async {
    // set loading to true
    setLoading(true);
    // a reaction is saved as senderUID=reaction
    String reactionToAdd = '$senderUID=$reaction';

    try {
      // 1. check if its a group message
      if (groupId) {
        // 2. get the reaction list from firestore
        final messageData = await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .get();

        // 3. add the meesaage data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // 4. check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // 5. add the reaction to the message
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageId)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          // 6. get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('=')[0]).toList();

          // 7. check if the reaction is already added
          if (uids.contains(senderUID)) {
            // 8. get the index of the reaction
            final index = uids.indexOf(senderUID);
            // 9. replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // 10. add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // 11. update the message
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageId)
              .update({Constants.reactions: message.reactions});
        }
      } else {
        // handle contact message
        // 2. get the reaction list from firestore
        final messageData = await _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .get();

        // 3. add the meesaage data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // 4. check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // 5. add the reaction to the message
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageId)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          // 6. get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('=')[0]).toList();

          // 7. check if the reaction is already added
          if (uids.contains(senderUID)) {
            // 8. get the index of the reaction
            final index = uids.indexOf(senderUID);
            // 9. replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // 10. add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // 11. update the message to sender firestore location
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageId)
              .update({Constants.reactions: message.reactions});

          // 12. update the message to contact firestore location
          await _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(senderUID)
              .collection(Constants.messages)
              .doc(messageId)
              .update({Constants.reactions: message.reactions});
        }
      }

      // set loading to false
      setLoading(false);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // get chatsList stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
    required String isGroup,
  }) {
    // 1. check if its a group message
    if (isGroup.isNotEmpty) {
      // handle group message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    } else {
      // handle contact message
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }
  }

  Stream<int> getUnreadMessagesStream({
    required String userId,
    required String contactUID,
    required bool isGroup,
  }) {
    // 1. check if its a group message
    if (isGroup) {
      // handle group message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .asyncMap((event) {
        int count = 0;
        for (var doc in event.docs) {
          final message = MessageModel.fromMap(doc.data());
          if (!message.isSeenBy.contains(userId)) {
            count++;
          }
        }
        return count;
      });
    } else {
      // handle contact message
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .where(Constants.isSeen, isEqualTo: false)
          .where(Constants.senderUID, isNotEqualTo: userId)
          .snapshots()
          .map((event) => event.docs.length);
    }
  }

  // set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required List<String> isSeenByList,
    required bool isGroupChat,
  }) async {
    if (isGroupChat) {
      if (isSeenByList.contains(currentUserId)) {
        return;
      } else {
        await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({
          Constants.isSeenBy: FieldValue.arrayUnion([currentUserId]),
        });
      }
    } else {
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});

      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .update({Constants.isSeen: true});

      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .update({Constants.isSeen: true});
    }
  }

  Future<void> deleteMessage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
    required bool isGroupChat,
    required bool deleteForEveryone,
  }) async {
    setLoading(true);
    if (isGroupChat) {
      await _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });
      if (deleteForEveryone) {
        final groupData =
            await _firestore.collection(Constants.groups).doc(contactUID).get();
        final List<String> groupMembers =
            List<String>.from(groupData.data()![Constants.membersUIDs]);
        await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({Constants.deletedBy: FieldValue.arrayUnion(groupMembers)});

        if (messageType != MessageEnum.text.name) {
          await deleteFileFromStorage(
            currentUserId: currentUserId,
            contactUID: contactUID,
            messageId: messageId,
            messageType: messageType,
          );
        }
      }
      setLoading(false);
    } else {
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });
      if (!deleteForEveryone) {
        setLoading(false);
        return;
      }
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageId)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });
      if (messageType != MessageEnum.text.name) {
        await deleteFileFromStorage(
          currentUserId: currentUserId,
          contactUID: contactUID,
          messageId: messageId,
          messageType: messageType,
        );
      }
      setLoading(false);
    }
  }

  Future<void> deleteFileFromStorage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
  }) async {
    final firebaseStorage = FirebaseStorage.instance;
    await firebaseStorage
        .ref(
            '${Constants.chatFiles}/$messageType/$currentUserId/$contactUID/$messageId')
        .delete();
  }

  Stream<QuerySnapshot> getLastMessageStream({
    required String userId,
    required String groupId,
  }) {
    return groupId.isNotEmpty
        ? _firestore
            .collection(Constants.groups)
            .where(Constants.membersUIDs, arrayContains: userId)
            .snapshots()
        : _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .snapshots();
  }
}
