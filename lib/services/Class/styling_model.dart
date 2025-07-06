// class GeneratedLook {
//   final String? type; // 'wardrobe' or 'ai_suggestion'
//   final String? image; // base64 image string
//   final String? description;
//   final String? itemName; // only for wardrobe
//   final String? itemId; // only for wardrobe
//   final int? lookNumber; // only for ai_suggestion

//   GeneratedLook({
//     this.type,
//     this.image,
//     this.description,
//     this.itemName,
//     this.itemId,
//     this.lookNumber,
//   });

//   factory GeneratedLook.fromJson(Map<String, dynamic> json) {
//     return GeneratedLook(
//       type: json['type'] ?? 'unknown', // default fallback
//       image: json['imageB64'] ?? '', // fallback to empty string
//       itemName: json['itemName'],
//       itemId: json['itemId'],
//       description: json['description'],
//       lookNumber: json['lookNumber'],
//     );
//   }
// }

// class GeneratedOccasionResponse {
//   final String message;
//   final String occasion;
//   final bool wardrobeItemUsed;
//   final int totalImages;
//   final int wardrobeItemsAvailable;
//   final int aiSuggestionsGenerated; // ✅ Added this field
//   final List<GeneratedLook?> results;

//   GeneratedOccasionResponse({
//     required this.message,
//     required this.occasion,
//     required this.wardrobeItemUsed,
//     required this.totalImages,
//     required this.wardrobeItemsAvailable,
//     required this.aiSuggestionsGenerated,
//     required this.results,
//   });

//   factory GeneratedOccasionResponse.fromJson(Map<String, dynamic> json) {
//     return GeneratedOccasionResponse(
//       message: json['message'] ?? '',
//       occasion: json['occasion'] ?? '',
//       wardrobeItemUsed: json['wardrobeItemUsed'] ?? false,
//       totalImages: json['totalImages'] ?? 0,
//       wardrobeItemsAvailable: json['wardrobeItemsAvailable'] ?? 0,
//       aiSuggestionsGenerated:
//           json['aiSuggestionsGenerated'] ?? 0, // ✅ Added here
//       results:
//           (json['results'] as List<dynamic>?)
//               ?.where((item) => item != null)
//               .map(
//                 (item) => GeneratedLook.fromJson(item as Map<String, dynamic>),
//               )
//               .toList() ??
//           [],
//     );
//   }
// }

// //----------------------------------------------------------------------------------------------------------------------------------------------------------------

// class StyledOutfitResponse {
//   final String recommendations;
//   final String occasion;
//   final bool isPerfectMatch;
//   final List<ResultItem?> results;
//   final List<BadItemReason> badItemReasons;
//   final Map<String, SuitabilityDetail> suitabilityDetails;
//   final FashionAnalysisResponse fashionAnalysis;

//   StyledOutfitResponse({
//     required this.recommendations,
//     required this.occasion,
//     required this.isPerfectMatch,
//     required this.results,
//     required this.badItemReasons,
//     required this.suitabilityDetails,
//     required this.fashionAnalysis,
//   });

//   factory StyledOutfitResponse.fromJson(Map<String, dynamic> json) {
//     return StyledOutfitResponse(
//       recommendations: json['recommendations'] ?? '',
//       occasion: json['occasion'] ?? '',
//       isPerfectMatch: json['isPerfectMatch'] ?? false,
//       results:
//           (json['results'] as List?)
//               ?.where((e) => e != null)
//               .expand((e) => e is List ? e : [e])
//               .where((e) => e != null)
//               .map((e) => ResultItem.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       badItemReasons:
//           (json['badItemReasons'] as List?)
//               ?.where((e) => e != null)
//               .map((e) => BadItemReason.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       suitabilityDetails:
//           (json['suitabilityDetails'] as Map<String, dynamic>?)?.map(
//             (key, value) => MapEntry(
//               key,
//               value != null
//                   ? SuitabilityDetail.fromJson(value as Map<String, dynamic>)
//                   : SuitabilityDetail(status: '', reasoning: ''),
//             ),
//           ) ??
//           {},
//       fashionAnalysis: FashionAnalysisResponse.fromJson(
//         json['fashionAnalysis'] ?? {},
//       ),
//     );
//   }
// }

// class BadItemReason {
//   final String imageUrl;
//   final String itemType;
//   final String reason;
//   final String status;

//   BadItemReason({
//     required this.imageUrl,
//     required this.itemType,
//     required this.reason,
//     required this.status,
//   });

//   factory BadItemReason.fromJson(Map<String, dynamic> json) {
//     return BadItemReason(
//       imageUrl: json['imageUrl'] ?? '',
//       itemType: json['itemType'] ?? '',
//       reason: json['reason'] ?? '',
//       status: json['status'] ?? '',
//     );
//   }
// }

// class ResultItem {
//   final String? type;
//   final String? imageB64;
//   final String? description;

//   ResultItem({this.type, this.imageB64, this.description});

//   factory ResultItem.fromJson(Map<String, dynamic> json) {
//     return ResultItem(
//       type: json['type'] ?? '',
//       imageB64: json['imageB64'],
//       description: json['description'],
//     );
//   }
// }

// class SuitabilityDetail {
//   final String status;
//   final String reasoning;

//   SuitabilityDetail({required this.status, required this.reasoning});

//   factory SuitabilityDetail.fromJson(Map<String, dynamic> json) {
//     return SuitabilityDetail(
//       status: json['status'] ?? '',
//       reasoning: json['reasoning'] ?? '',
//     );
//   }
// }

// class FashionAnalysisResponse {
//   final List<GeneratedImageAnalysis> generatedImages;
//   final List<BadImageAnalysis> badImages;

//   FashionAnalysisResponse({
//     required this.generatedImages,
//     required this.badImages,
//   });

//   factory FashionAnalysisResponse.fromJson(Map<String, dynamic> json) {
//     return FashionAnalysisResponse(
//       generatedImages: (json['generatedImages'] as List)
//           .map((item) => GeneratedImageAnalysis.fromJson(item))
//           .toList(),
//       badImages: (json['badImages'] as List)
//           .map((item) => BadImageAnalysis.fromJson(item))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'generatedImages': generatedImages.map((e) => e.toJson()).toList(),
//     'badImages': badImages.map((e) => e.toJson()).toList(),
//   };
// }

// class GeneratedImageAnalysis {
//   final String? imageUrl;
//   final String brief;
//   final List<String> keywords;

//   GeneratedImageAnalysis({
//     this.imageUrl,
//     required this.brief,
//     required this.keywords,
//   });

//   factory GeneratedImageAnalysis.fromJson(Map<String, dynamic> json) {
//     return GeneratedImageAnalysis(
//       imageUrl: json['imageUrl'],
//       brief: json['brief'] ?? '',
//       keywords: List<String>.from(json['keywords'] ?? []),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'imageUrl': imageUrl,
//     'brief': brief,
//     'keywords': keywords,
//   };
// }

// class BadImageAnalysis {
//   final String? imageUrl;
//   final String reasoning;
//   final List<String> keywords;

//   BadImageAnalysis({
//     this.imageUrl,
//     required this.reasoning,
//     required this.keywords,
//   });

//   factory BadImageAnalysis.fromJson(Map<String, dynamic> json) {
//     return BadImageAnalysis(
//       imageUrl: json['imageUrl'],
//       reasoning: json['reasoning'] ?? '',
//       keywords: List<String>.from(json['keywords'] ?? []),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'imageUrl': imageUrl,
//     'reasoning': reasoning,
//     'keywords': keywords,
//   };
// }

//------------------------------------------------------------------------------------------------------
class OutfitAnalysisResponse {
  final List<ResultItem> results;
  final ImageAnalysis imageAnalysis;

  OutfitAnalysisResponse({required this.results, required this.imageAnalysis});

  factory OutfitAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return OutfitAnalysisResponse(
      results: (json['results'] as List)
          .map((e) => ResultItem.fromJson(e))
          .toList(),
      imageAnalysis: ImageAnalysis.fromJson(json['imageAnalysis']),
    );
  }
}

class ResultItem {
  final String type;
  final String imageUrl;

  ResultItem({required this.type, required this.imageUrl});

  factory ResultItem.fromJson(Map<String, dynamic> json) {
    return ResultItem(type: json['type'], imageUrl: json['imageUrl']);
  }
}

class ImageAnalysis {
  final List<ImageWithDescription> goodImageWithDescription;
  final List<ImageWithDescription> badImageWithDescription;
  final List<String> goodImagesKeywords;
  final List<String> badImagesKeywords;

  ImageAnalysis({
    required this.goodImageWithDescription,
    required this.badImageWithDescription,
    required this.goodImagesKeywords,
    required this.badImagesKeywords,
  });

  factory ImageAnalysis.fromJson(Map<String, dynamic> json) {
    return ImageAnalysis(
      goodImageWithDescription: (json['goodImageWithDescription'] as List)
          .map((item) => ImageWithDescription.fromJson(item))
          .toList(),
      badImageWithDescription: (json['badImageWithDescription'] ?? [])
          .map<ImageWithDescription>(
            (item) => ImageWithDescription.fromJson(item),
          )
          .toList(),
      goodImagesKeywords: List<String>.from(json['goodImagesKeywords'] ?? []),
      badImagesKeywords: List<String>.from(json['badImagesKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goodImageWithDescription': goodImageWithDescription
          .map((e) => e.toJson())
          .toList(),
      'badImageWithDescription': badImageWithDescription
          .map((e) => e.toJson())
          .toList(),
      'goodImagesKeywords': goodImagesKeywords,
      'badImagesKeywords': badImagesKeywords,
    };
  }
}

class ImageWithDescription {
  final String image;
  final String description;

  ImageWithDescription({required this.image, required this.description});

  factory ImageWithDescription.fromJson(Map<String, dynamic> json) {
    return ImageWithDescription(
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'image': image, 'description': description};
  }
}
