class FavouritesResponse {
  final String msg;
  final int count;
  final List<SavedFavouriteData> data;

  FavouritesResponse({
    required this.msg,
    required this.count,
    required this.data,
  });

  factory FavouritesResponse.fromJson(Map<String, dynamic> json) {
    return FavouritesResponse(
      msg: json['msg'],
      count: json['count'],
      data: List<SavedFavouriteData>.from(
        json['data'].map((item) => SavedFavouriteData.fromJson(item)),
      ),
    );
  }
}

class SavedFavouriteResponse {
  final SavedFavouriteData data;
  final String msg;

  SavedFavouriteResponse({required this.data, required this.msg});

  factory SavedFavouriteResponse.fromJson(Map<String, dynamic> json) {
    return SavedFavouriteResponse(
      data: SavedFavouriteData.fromJson(json['data']),
      msg: json['msg'],
    );
  }
}

class SavedFavouriteData {
  final String userId;
  final String imageUrl;
  final String tag;
  final String occasion;
  final String description;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  SavedFavouriteData({
    required this.userId,
    required this.imageUrl,
    required this.tag,
    required this.occasion,
    required this.description,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SavedFavouriteData.fromJson(Map<String, dynamic> json) {
    return SavedFavouriteData(
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      tag: json['tag'],
      occasion: json['occasion'],
      description: json['description'],
      id: json['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}
