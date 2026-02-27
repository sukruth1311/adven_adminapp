class MembershipRequest {
  final String id;
  final String userId;
  final String requestedPlanId;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  MembershipRequest({
    required this.id,
    required this.userId,
    required this.requestedPlanId,
    required this.status,
    required this.createdAt,
  });

  factory MembershipRequest.fromJson(Map<String, dynamic> json) {
    return MembershipRequest(
      id: json['id'],
      userId: json['userId'],
      requestedPlanId: json['requestedPlanId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  factory MembershipRequest.empty() {
    return MembershipRequest(
      id: '',
      userId: '',
      requestedPlanId: '',
      status: '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'requestedPlanId': requestedPlanId,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
