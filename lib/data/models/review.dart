class Review {
  final String id;
  final String userId;
  final String targetId;
  final int rating;
  final String comment;
  final bool isApproved;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.isApproved,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      targetId: json['targetId'],
      rating: json['rating'],
      comment: json['comment'],
      isApproved: json['isApproved'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'targetId': targetId,
    'rating': rating,
    'comment': comment,
    'isApproved': isApproved,
    'createdAt': createdAt.toIso8601String(),
  };
}
