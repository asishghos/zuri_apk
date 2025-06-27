class ProductClass {
  final String? keyword;
  final String? platform;
  final String? title;
  final String? originalLink;
  final String? affiliatedLink;
  final String? thumbnail;

  ProductClass({
    this.keyword,
    this.platform,
    this.title,
    this.originalLink,
    this.affiliatedLink,
    this.thumbnail,
  });

  factory ProductClass.fromJson(Map<String, dynamic> json) {
    return ProductClass(
      keyword: json['keyword'] as String?,
      platform: json['platform'] as String?,
      title: json['title'] as String?,
      originalLink: json['original_link'] as String?,
      affiliatedLink: json['affiliated_link'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'platform': platform,
      'title': title,
      'original_link': originalLink,
      'affiliated_link': affiliatedLink,
      'thumbnail': thumbnail,
    };
  }
}
