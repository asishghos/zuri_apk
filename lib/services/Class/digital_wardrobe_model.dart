class DigitalWardrobeResponse {
  final String message;
  final int processed;
  final int skipped;
  final int total;

  DigitalWardrobeResponse({
    required this.message,
    required this.processed,
    required this.skipped,
    required this.total,
  });

  factory DigitalWardrobeResponse.fromJson(Map<String, dynamic> json) {
    return DigitalWardrobeResponse(
      message: json['message'] ?? '',
      processed: json['processed'] ?? 0,
      skipped: json['skipped'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class GarmentItem {
  final String imageId;
  final String itemName;
  final String imageUrl;
  final String garmentId;
  final DateTime createdAt;

  GarmentItem({
    required this.imageId,
    required this.itemName,
    required this.imageUrl,
    required this.garmentId,
    required this.createdAt,
  });

  factory GarmentItem.fromJson(Map<String, dynamic> json) {
    return GarmentItem(
      imageId: json['imageId'],
      garmentId: json['garmentId'],
      itemName: json['itemName'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CategoryCounts {
  final Map<String, int> counts;

  CategoryCounts({required this.counts});

  factory CategoryCounts.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'] as Map<String, dynamic>;
    final converted = rawCounts.map(
      (key, value) => MapEntry(key, value as int),
    );

    return CategoryCounts(counts: converted);
  }
}

class GarmentColor {
  final String name;
  final String hex;

  GarmentColor({required this.name, required this.hex});

  factory GarmentColor.fromJson(Map<String, dynamic> json) {
    return GarmentColor(name: json['name'], hex: json['hex']);
  }
}

class GarmentDetails {
  final String imageId;
  final String itemName;
  final String category;
  final GarmentColor color;
  final String fabric;
  final String garmentId;
  final List<String> occasion;
  final List<String> season;
  final String imageUrl;
  final DateTime createdAt;

  GarmentDetails({
    required this.imageId,
    required this.itemName,
    required this.category,
    required this.color,
    required this.fabric,
    required this.garmentId,
    required this.occasion,
    required this.season,
    required this.imageUrl,
    required this.createdAt,
  });

  factory GarmentDetails.fromJson(Map<String, dynamic> json) {
    return GarmentDetails(
      imageId: json['imageId'],
      itemName: json['itemName'],
      category: json['category'],
      color: GarmentColor.fromJson(json['color']),
      fabric: json['fabric'],
      garmentId: json['garmentId'],
      occasion: List<String>.from(json['occasion']),
      season: List<String>.from(json['season']),
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MismatchedGarment {
  final String filename;
  final String imageUrl;
  final String reason;
  final List<String> suggestedCategories;

  MismatchedGarment({
    required this.filename,
    required this.imageUrl,
    required this.reason,
    required this.suggestedCategories,
  });

  factory MismatchedGarment.fromJson(Map<String, dynamic> json) {
    return MismatchedGarment(
      filename: json['filename'],
      imageUrl: json['imageUrl'],
      reason: json['reason'],
      suggestedCategories: List<String>.from(json['suggestedCategories']),
    );
  }
}

class CategoryUploadResult {
  final String message;
  final List<MismatchedGarment> mismatched;

  CategoryUploadResult({required this.message, required this.mismatched});

  factory CategoryUploadResult.fromJson(Map<String, dynamic> json) {
    return CategoryUploadResult(
      message: json['message'],
      mismatched: (json['mismatched'] as List)
          .map((item) => MismatchedGarment.fromJson(item))
          .toList(),
    );
  }
}
