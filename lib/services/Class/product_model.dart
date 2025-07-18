class ProductItem {
  final String keyword;
  final String source;
  final String title;
  final String price;
  final String rating; // keep it string for display purposes
  final String productId;

  ProductItem({
    required this.keyword,
    required this.source,
    required this.title,
    required this.price,
    required this.rating,
    required this.productId,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      keyword: json['keyword'] ?? '',
      source: json['source'] ?? '',
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'source': source,
      'title': title,
      'price': price,
      'rating': rating,
      'product_id': productId,
    };
  }
}
