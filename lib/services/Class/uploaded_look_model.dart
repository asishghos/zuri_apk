class UploadedLook {
  final String id;
  final String userId;
  final String imageUrl;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  UploadedLook({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UploadedLook.fromJson(Map<String, dynamic> json) {
    return UploadedLook(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
