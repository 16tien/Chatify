// models/call_model.dart
class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String status; // ringing, accepted, cancelled

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'],
      callerId: map['callerId'],
      callerName: map['callerName'],
      receiverId: map['receiverId'],
      receiverName: map['receiverName'],
      status: map['status'],
    );
  }
}
