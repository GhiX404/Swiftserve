class RfidMapping {
  final String rfidUid;
  final int studentId;

  RfidMapping({
    required this.rfidUid,
    required this.studentId,
  });

  factory RfidMapping.fromJson(Map<String, dynamic> json) {
    return RfidMapping(
      rfidUid: json['rfidUid'],
      studentId: json['studentId'],
    );
  }
} 