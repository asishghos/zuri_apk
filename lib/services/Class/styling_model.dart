class GeneratedLook {
  final String? type; // 'wardrobe' or 'ai_suggestion'
  final String? image; // base64 image string
  final String? description;
  final String? itemName; // only for wardrobe
  final String? itemId; // only for wardrobe
  final int? lookNumber; // only for ai_suggestion

  GeneratedLook({
    this.type,
    this.image,
    this.description,
    this.itemName,
    this.itemId,
    this.lookNumber,
  });

  factory GeneratedLook.fromJson(Map<String, dynamic> json) {
    return GeneratedLook(
      type: json['type'] ?? 'unknown', // default fallback
      image: json['imageB64'] ?? '', // fallback to empty string
      itemName: json['itemName'],
      itemId: json['itemId'],
      description: json['description'],
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
  final int aiSuggestionsGenerated; // ✅ Added this field
  final List<GeneratedLook?> results;

  GeneratedOccasionResponse({
    required this.message,
    required this.occasion,
    required this.wardrobeItemUsed,
    required this.totalImages,
    required this.wardrobeItemsAvailable,
    required this.aiSuggestionsGenerated,
    required this.results,
  });

  factory GeneratedOccasionResponse.fromJson(Map<String, dynamic> json) {
    return GeneratedOccasionResponse(
      message: json['message'] ?? '',
      occasion: json['occasion'] ?? '',
      wardrobeItemUsed: json['wardrobeItemUsed'] ?? false,
      totalImages: json['totalImages'] ?? 0,
      wardrobeItemsAvailable: json['wardrobeItemsAvailable'] ?? 0,
      aiSuggestionsGenerated:
          json['aiSuggestionsGenerated'] ?? 0, // ✅ Added here
      results:
          (json['results'] as List<dynamic>?)
              ?.where((item) => item != null)
              .map(
                (item) => GeneratedLook.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------

class StyledOutfitResponse {
  final String recommendations;
  final String occasion;
  final bool isPerfectMatch;
  final List<ResultItem?> results;
  final List<BadItemReason> badItemReasons;
  final Map<String, SuitabilityDetail> suitabilityDetails;

  StyledOutfitResponse({
    required this.recommendations,
    required this.occasion,
    required this.isPerfectMatch,
    required this.results,
    required this.badItemReasons,
    required this.suitabilityDetails,
  });

  factory StyledOutfitResponse.fromJson(Map<String, dynamic> json) {
    return StyledOutfitResponse(
      recommendations: json['recommendations'] ?? '',
      occasion: json['occasion'] ?? '',
      isPerfectMatch: json['isPerfectMatch'] ?? false,
      results:
          (json['results'] as List?)
              ?.where((e) => e != null)
              .expand((e) => e is List ? e : [e])
              .where((e) => e != null)
              .map((e) => ResultItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      badItemReasons:
          (json['badItemReasons'] as List?)
              ?.where((e) => e != null)
              .map((e) => BadItemReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suitabilityDetails:
          (json['suitabilityDetails'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              value != null
                  ? SuitabilityDetail.fromJson(value as Map<String, dynamic>)
                  : SuitabilityDetail(status: '', reasoning: ''),
            ),
          ) ??
          {},
    );
  }
}

class BadItemReason {
  final String imageUrl;
  final String itemType;
  final String reason;
  final String status;

  BadItemReason({
    required this.imageUrl,
    required this.itemType,
    required this.reason,
    required this.status,
  });

  factory BadItemReason.fromJson(Map<String, dynamic> json) {
    return BadItemReason(
      imageUrl: json['imageUrl'] ?? '',
      itemType: json['itemType'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class ResultItem {
  final String? type;
  final String? imageB64;
  final String? description;

  ResultItem({this.type, this.imageB64, this.description});

  factory ResultItem.fromJson(Map<String, dynamic> json) {
    return ResultItem(
      type: json['type'] ?? '',
      imageB64: json['imageB64'],
      description: json['description'],
    );
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
