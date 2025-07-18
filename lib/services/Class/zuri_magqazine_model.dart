class ZuriCategoriesResponse {
  final List<String> data;
  final String msg;

  ZuriCategoriesResponse({required this.data, required this.msg});

  factory ZuriCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return ZuriCategoriesResponse(
      data: List<String>.from(json['data']),
      msg: json['msg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'msg': msg};
  }
}

class ZuriMagazine {
  final String id;
  final String authorProfilePic;
  final String authorName;
  final String category;
  final String title;
  final String content;
  final String subTitle;
  final String bannerImage;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZuriMagazine({
    required this.id,
    required this.authorProfilePic,
    required this.authorName,
    required this.category,
    required this.title,
    required this.content,
    required this.subTitle,
    required this.bannerImage,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ZuriMagazine.fromJson(Map<String, dynamic> json) {
    return ZuriMagazine(
      id: json['_id'],
      authorProfilePic: json['authorProfilePic'],
      authorName: json['authorName'],
      category: json['category'],
      title: json['title'],
      content: json['content'],
      subTitle: json['subTitle'],
      bannerImage: json['bannerImage'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'authorProfilePic': authorProfilePic,
      'authorName': authorName,
      'category': category,
      'title': title,
      'content': content,
      'subTitle': subTitle,
      'bannerImage': bannerImage,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
