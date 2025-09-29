import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/constants/constants.dart';
import 'package:chat_app/features/groups/data/models/group_model.dart';
import 'package:chat_app/features/chat/data/message_model.dart';
import 'package:chat_app/features/authentication/data/user_model.dart';
import 'package:chat_app/core/utils/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/enums.dart';

class GroupProvider extends ChangeNotifier {
  bool _isLoading = false;

  GroupModel _groupModel = GroupModel(
    creatorUID: '',
    groupName: '',
    groupDescription: '',
    groupImage: '',
    groupId: '',
    lastMessage: '',
    senderUID: '',
    messageType: MessageEnum.text,
    messageId: '',
    timeSent: DateTime.now(),
    createdAt: DateTime.now(),
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMessages: false,
    requestToJoin: false,
    membersUIDs: [],
    adminsUIDs: [],
    awaitingApprovalUIDs: [],
  );
  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

  List<UserModel> _tempGroupMembersList = [];
  List<UserModel> _tempGoupAdminsList = [];

  List<String> _tempGroupMemberUIDs = [];
  List<String> _tempGroupAdminUIDs = [];

  List<UserModel> _tempRemovedAdminsList = [];
  List<UserModel> _tempRemovedMembersList = [];

  List<String> _tempRemovedMemberUIDs = [];
  List<String> _tempRemovedAdminsUIDs = [];

  bool _isSaved = false;

  bool get isLoading => _isLoading;

  GroupModel get groupModel => _groupModel;

  List<UserModel> get groupMembersList => _groupMembersList;

  List<UserModel> get groupAdminsList => _groupAdminsList;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // setters
  void setIsSloading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setEditSettings({required bool value}) {
    _groupModel.editSettings = value;
    notifyListeners();
    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setApproveNewMembers({required bool value}) {
    _groupModel.approveMembers = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setRequestToJoin({required bool value}) {
    _groupModel.requestToJoin = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setLockMessages({required bool value}) {
    _groupModel.lockMessages = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<void> updateGroupDataInFireStore() async {
    try {
      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update(groupModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> setEmptyTemps() async {
    _isSaved = false;
    _tempGoupAdminsList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMemberUIDs = [];
    _tempGroupAdminUIDs = [];
    _tempRemovedMemberUIDs = [];
    _tempRemovedAdminsUIDs = [];
    _tempRemovedMembersList = [];
    _tempRemovedAdminsList = [];

    notifyListeners();
  }
  Future<void> removeTempLists({required bool isAdmins}) async {
    if (_isSaved) return;
    if (isAdmins) {
      if (_tempGoupAdminsList.isNotEmpty) {
        _groupAdminsList.removeWhere((admin) =>
            _tempGoupAdminsList.any((tempAdmin) => tempAdmin.uid == admin.uid));
        _groupModel.adminsUIDs.removeWhere((adminUid) =>
            _tempGroupAdminUIDs.any((tempUid) => tempUid == adminUid));
        notifyListeners();
      }

      if (_tempRemovedAdminsList.isNotEmpty) {
        _groupAdminsList.addAll(_tempRemovedAdminsList);
        _groupModel.adminsUIDs.addAll(_tempRemovedAdminsUIDs);
        notifyListeners();
      }
    } else {
      if (_tempGroupMembersList.isNotEmpty) {
        _groupMembersList.removeWhere((member) => _tempGroupMembersList
            .any((tempMember) => tempMember.uid == member.uid));
        _groupModel.membersUIDs.removeWhere((memberUid) =>
            _tempGroupMemberUIDs.any((tempUid) => tempUid == memberUid));
        notifyListeners();
      }

      if (_tempRemovedMembersList.isNotEmpty) {
        _groupMembersList.addAll(_tempRemovedMembersList);
        _groupModel.membersUIDs.addAll(_tempGroupMemberUIDs);
        notifyListeners();
      }
    }
  }

  Future<void> updateGroupDataInFireStoreIfNeeded() async {
    _isSaved = true;
    notifyListeners();
    await updateGroupDataInFireStore();
  }

  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _groupModel.membersUIDs.add(groupMember.uid);
    _tempGroupMembersList.add(groupMember);
    _tempGroupMemberUIDs.add(groupMember.uid);
    notifyListeners();

  }

  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _groupModel.adminsUIDs.add(groupAdmin.uid);
    _tempGoupAdminsList.add(groupAdmin);
    _tempGroupAdminUIDs.add(groupAdmin.uid);
    notifyListeners();

  }

  void setGroupImage(String groupImage) {
    _groupModel.groupImage = groupImage;
    notifyListeners();
  }

  void setGroupName(String groupName) {
    _groupModel.groupName = groupName;
    notifyListeners();
  }

  void setGroupDescription(String groupDescription) {
    _groupModel.groupDescription = groupDescription;
    notifyListeners();
  }

  Future<void> setGroupModel({required GroupModel groupModel}) async {
    _groupModel = groupModel;
    notifyListeners();
  }

  Future<void> removeGroupMember({required UserModel groupMember}) async {
    _groupMembersList.remove(groupMember);
    _groupAdminsList.remove(groupMember);
    _groupModel.membersUIDs.remove(groupMember.uid);

    _tempGroupMembersList.remove(groupMember);
    _tempGroupAdminUIDs.remove(groupMember.uid);

    _tempRemovedMembersList.add(groupMember);
    _tempRemovedMemberUIDs.add(groupMember.uid);

    notifyListeners();

    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);
    _tempGroupAdminUIDs.remove(groupAdmin.uid);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);

    _tempRemovedAdminsList.add(groupAdmin);
    _tempRemovedAdminsUIDs.add(groupAdmin.uid);
    notifyListeners();

    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<List<UserModel>> getGroupMembersDataFromFirestore({
    required bool isAdmin,
  }) async {
    try {
      List<UserModel> membersData = [];

      List<String> membersUIDs =
          isAdmin ? _groupModel.adminsUIDs : _groupModel.membersUIDs;

      for (var uid in membersUIDs) {
        var user = await _firestore.collection(Constants.users).doc(uid).get();
        membersData.add(UserModel.fromMap(user.data()!));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateGroupMembersList() async {
    _groupMembersList.clear();

    _groupMembersList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: false));

    notifyListeners();
  }

  Future<void> updateGroupAdminsList() async {
    _groupAdminsList.clear();

    _groupAdminsList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: true));

    notifyListeners();
  }

  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _groupModel = GroupModel(
      creatorUID: '',
      groupName: '',
      groupDescription: '',
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoin: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    notifyListeners();
  }

  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }


  Stream<DocumentSnapshot> groupStream({required String groupId}) {
    return _firestore.collection(Constants.groups).doc(groupId).snapshots();
  }

  streamGroupMembersData({required List<String> membersUIDs}) {
    return Stream.fromFuture(Future.wait<DocumentSnapshot>(
      membersUIDs.map<Future<DocumentSnapshot>>((uid) async {
        return await _firestore.collection(Constants.users).doc(uid).get();
      }),
    ));
  }

  Future<void> createGroup({
    required GroupModel newGroupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    setIsSloading(value: true);

    try {
      var groupId = const Uuid().v4();
      newGroupModel.groupId = groupId;

      if (fileImage != null) {
        final String imageUrl = await storeFileToCloudinary(
            file: fileImage, reference: '${Constants.groupImages}/$groupId');
        newGroupModel.groupImage = imageUrl;
      }

      newGroupModel.adminsUIDs = [
        newGroupModel.creatorUID,
        ...getGroupAdminsUIDs()
      ];

      newGroupModel.membersUIDs = [
        newGroupModel.creatorUID,
        ...getGroupMembersUIDs()
      ];

      setGroupModel(groupModel: newGroupModel);

      await _firestore
          .collection(Constants.groups)
          .doc(groupId)
          .set(groupModel.toMap());

      setIsSloading(value: false);
      onSuccess();
    } catch (e) {
      setIsSloading(value: false);
      onFail(e.toString());
    }
  }

  Stream<List<GroupModel>> getPrivateGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.membersUIDs, arrayContains: userId)
        .where(Constants.isPrivate, isEqualTo: true)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => GroupModel.fromMap(doc.data())).toList());
  }

  Stream<List<GroupModel>> getPublicGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.isPrivate, isEqualTo: false)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }

      return groups;
    });
  }

  void changeGroupType() {
    _groupModel.isPrivate = !_groupModel.isPrivate;
    notifyListeners();
    updateGroupDataInFireStore();
  }

  Future<void> sendRequestToJoinGroup({
    required String groupId,
    required String uid,
    required String groupName,
    required String groupImage,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.awaitingApprovalUIDs: FieldValue.arrayUnion([uid])
    });

  }

  Future<void> acceptRequestToJoinGroup({
    required String groupId,
    required String friendID,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.membersUIDs: FieldValue.arrayUnion([friendID]),
      Constants.awaitingApprovalUIDs: FieldValue.arrayRemove([friendID])
    });

    _groupModel.awaitingApprovalUIDs.remove(friendID);
    _groupModel.membersUIDs.add(friendID);
    notifyListeners();
  }


  bool isSenderOrAdmin({required MessageModel message, required String uid}) {
    if (message.senderUID == uid) {
      return true;
    } else if (_groupModel.adminsUIDs.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> exitGroup({
    required String uid,
  }) async {
    bool isAdmin = _groupModel.adminsUIDs.contains(uid);

    await _firestore
        .collection(Constants.groups)
        .doc(_groupModel.groupId)
        .update({
      Constants.membersUIDs: FieldValue.arrayRemove([uid]),
      Constants.adminsUIDs:
          isAdmin ? FieldValue.arrayRemove([uid]) : _groupModel.adminsUIDs,
    });

    _groupMembersList.removeWhere((element) => element.uid == uid);
    _groupModel.membersUIDs.remove(uid);
    if (isAdmin) {
      _groupAdminsList.removeWhere((element) => element.uid == uid);
      _groupModel.adminsUIDs.remove(uid);
    }
    notifyListeners();
  }
}
