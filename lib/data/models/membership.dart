class Membership {
  final String id;
  final String userId;
  final String planName;
  final DateTime expiryDate;

  Membership({
    required this.id,
    required this.userId,
    required this.planName,
    required this.expiryDate,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      userId: json['userId'],
      planName: json['planName'],
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'planName': planName,
    'expiryDate': expiryDate.toIso8601String(),
  };
}
