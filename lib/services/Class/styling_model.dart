class GeneratedLook {
  final String type; // 'wardrobe' or 'ai_suggestion'
  final String image; // base64 image string
  final String? itemName; // only for wardrobe
  final String? itemId; // only for wardrobe
  final int? lookNumber; // only for ai_suggestion

  GeneratedLook({
    required this.type,
    required this.image,
    this.itemName,
    this.itemId,
    this.lookNumber,
  });

  factory GeneratedLook.fromJson(Map<String, dynamic> json) {
    return GeneratedLook(
      type: json['type'],
      image: json['image'],
      itemName: json['itemName'],
      itemId: json['itemId'],
      lookNumber: json['lookNumber'],
    );
  }
}

class GeneratedOccasionResponse {
  final String message;
  final String occasion;
  final bool wardrobeItemUsed;
  final int totalImages;
  final int wardrobeItemsAvailable;
  final List<GeneratedLook> results;

  GeneratedOccasionResponse({
    required this.message,
    required this.occasion,
    required this.wardrobeItemUsed,
    required this.totalImages,
    required this.wardrobeItemsAvailable,
    required this.results,
  });

  factory GeneratedOccasionResponse.fromJson(Map<String, dynamic> json) {
    return GeneratedOccasionResponse(
      message: json['message'],
      occasion: json['occasion'],
      wardrobeItemUsed: json['wardrobeItemUsed'],
      totalImages: json['totalImages'],
      wardrobeItemsAvailable: json['wardrobeItemsAvailable'],
      results: (json['results'] as List)
          .map((item) => GeneratedLook.fromJson(item))
          .toList(),
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------

class StyledOutfitResponse {
  final String recommendations;
  final String occasion;
  final bool isPerfectMatch;
  final List<ResultItem> results;
  final List<String> badItemImages;
  final Map<String, SuitabilityDetail> suitabilityDetails;

  StyledOutfitResponse({
    required this.recommendations,
    required this.occasion,
    required this.isPerfectMatch,
    required this.results,
    required this.badItemImages,
    required this.suitabilityDetails,
  });

  factory StyledOutfitResponse.fromJson(Map<String, dynamic> json) {
    return StyledOutfitResponse(
      recommendations: json['recommendations'] ?? '',
      occasion: json['occasion'] ?? '',
      isPerfectMatch: json['isPerfectMatch'] ?? false,
      results: (json['results'] as List)
          .expand((e) => e is List ? e : [e]) // flatten nested list
          .map((e) => ResultItem.fromJson(e))
          .toList(),
      badItemImages: (json['badItemImages'] as List)
          .map((e) => e.toString())
          .toList(),
      suitabilityDetails: (json['suitabilityDetails'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(key, SuitabilityDetail.fromJson(value)),
          ),
    );
  }
}

class ResultItem {
  final String type;
  final String? imageB64;

  ResultItem({required this.type, this.imageB64});

  factory ResultItem.fromJson(Map<String, dynamic> json) {
    return ResultItem(type: json['type'], imageB64: json['imageB64']);
  }
}

class SuitabilityDetail {
  final String status;
  final String reasoning;

  SuitabilityDetail({required this.status, required this.reasoning});

  factory SuitabilityDetail.fromJson(Map<String, dynamic> json) {
    return SuitabilityDetail(
      status: json['status'] ?? '',
      reasoning: json['reasoning'] ?? '',
    );
  }
}
