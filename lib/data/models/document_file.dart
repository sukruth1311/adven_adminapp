class DocumentFile {
  final String id;
  final String title; // renamed from fileName
  final String url;
  final bool isPublic;
  final DateTime uploadedAt;

  DocumentFile({
    required this.id,
    required this.title,
    required this.url,
    required this.isPublic,
    required this.uploadedAt,
  });

  factory DocumentFile.fromJson(Map<String, dynamic> json) {
    return DocumentFile(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      isPublic: json['isPublic'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'isPublic': isPublic,
    'uploadedAt': uploadedAt.toIso8601String(),
  };
}
