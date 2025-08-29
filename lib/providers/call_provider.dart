// providers/call_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_model.dart';

class CallProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> makeCall({required CallModel callModel}) async {
    await _firestore.collection('calls').doc(callModel.callId).set(callModel.toMap());
  }

  Stream<CallModel?> callStatusStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CallModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateCallStatus(String callId, String status) async {
    await _firestore.collection('calls').doc(callId).update({'status': status});
  }
}
