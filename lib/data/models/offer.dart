class Offer {
  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime validTill;
  final DateTime createdAt;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.validTill,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      validTill: DateTime.parse(json['validTill']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isActive': isActive,
      'validTill': validTill.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
