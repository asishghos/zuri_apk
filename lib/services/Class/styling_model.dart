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

class RecommendationCritique {
  final String itemName;
  final String feedback;

  RecommendationCritique({required this.itemName, required this.feedback});

  factory RecommendationCritique.fromJson(Map<String, dynamic> json) {
    return RecommendationCritique(
      itemName: json['itemName'],
      feedback: json['feedback'],
    );
  }
}

class StyleRecommendationResponse {
  final List<RecommendationCritique> recommendations;
  final String? modelImage; // base64 image
  final Map<String, dynamic>? wardrobeImage;
  final List<dynamic>? aiGeneratedImages;
  final bool hasWardrobeImage;
  final int aiImageCount;
  final String message;
  final List<String> badItemImages;
  final bool isPerfectMatch;
  final Map<String, dynamic>? suitabilityDetails;

  StyleRecommendationResponse({
    required this.recommendations,
    required this.modelImage,
    required this.wardrobeImage,
    required this.aiGeneratedImages,
    required this.hasWardrobeImage,
    required this.aiImageCount,
    required this.message,
    required this.badItemImages,
    required this.isPerfectMatch,
    required this.suitabilityDetails,
  });

  factory StyleRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return StyleRecommendationResponse(
      recommendations: (json['recommendations'] as List)
          .map((e) => RecommendationCritique.fromJson(e))
          .toList(),
      modelImage: json['modelImage'],
      wardrobeImage: json['wardrobeImage'],
      aiGeneratedImages: json['aiGeneratedImages'],
      hasWardrobeImage: json['hasWardrobeImage'] ?? false,
      aiImageCount: json['aiImageCount'] ?? 0,
      message: json['message'],
      badItemImages: List<String>.from(json['badItemImages'] ?? []),
      isPerfectMatch: json['isPerfectMatch'] ?? false,
      suitabilityDetails: json['suitabilityDetails'],
    );
  }
}
