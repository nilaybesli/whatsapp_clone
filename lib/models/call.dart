class Call {
  final String callerId;
  final String callerName;
  final String callerPic;
  final String recieverId;
  final String recieverName;
  final String recieverPic;
  final String callId;
  final bool hasDialled;

  Call({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.recieverName,
    required this.recieverId,
    required this.recieverPic,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'recieverName': recieverName,
      'recieverId': recieverId,
      'recieverPic': recieverPic,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] ?? '',
      recieverId: map['recieverId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPic: map['callerPic'] ?? '',
      hasDialled: map['hasDialled'] ?? false,
      recieverName: map['recieverName'] ?? '',
      recieverPic: map['recieverPic'] ?? '',
      callId: map['callId'] ?? '',
    );
  }
}
