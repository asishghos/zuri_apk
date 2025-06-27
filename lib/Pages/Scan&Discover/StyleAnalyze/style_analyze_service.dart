// services/style_analysis_service.dart
import 'package:testing2/Pages/Scan&Discover/StyleAnalyze/Models/body_shape.dart';
import 'package:testing2/Pages/Scan&Discover/StyleAnalyze/Models/skin_undertone.dart';

class StyleAnalysisService {
  /// Helper method to convert string to BodyShapeOption enum
  static BodyShapeOption? _getBodyShapeFromString(String bodyShapeString) {
    switch (bodyShapeString.toLowerCase()) {
      case 'apple':
      case 'Apple':
        return BodyShapeOption.apple;
      case 'pear':
      case 'Pear':
        return BodyShapeOption.pear;
      case 'rectangle':
      case 'Rectangle':
        return BodyShapeOption.rectangle;
      case 'hourglass':
      case 'Hourglass':
      case 'HourGlass':
      case 'hourGlass':
      case 'hour glass':
      case 'Hour glass':
      case 'Hour Glass':
      case 'hour Glass':
        return BodyShapeOption.hourglass;
      case 'inverted triangle':
      case 'invertedtriangle':
      case 'Inverted Triangle':
      case 'InvertedTriangle':
      case 'invertedTriangle':
      case 'inverted Triangle':
      case 'Inverted triangle':
      case 'Invertedtriangle':
        return BodyShapeOption.invertedTriangle;
      default:
        return null;
    }
  }

  /// Helper method to convert string to SkinUndertone enum
  static SkinUndertone? _getUndertoneFromString(String undertoneString) {
    switch (undertoneString.toLowerCase()) {
      case 'warm':
      case 'Warm':
        return SkinUndertone.warm;
      case 'cool':
      case 'Cool':
        return SkinUndertone.cool;
      case 'neutral':
      case 'Neutral':
        return SkinUndertone.neutral;
      default:
        return null;
    }
  }

  /// Returns outfit recommendations based on body shape and category
  static List<String> getOutfitRecommendations({
    required BodyShapeOption bodyShape,
    required String category, // 'tops', 'bottoms', 'dresses', 'indian'
  }) {
    final bodyShapeModel = BodyShapeData.getBodyShape(bodyShape);
    if (bodyShapeModel == null) return [];

    switch (category.toLowerCase()) {
      case 'tops':
        return bodyShapeModel.tops;
      case 'bottoms':
        return bodyShapeModel.bottoms;
      case 'dresses':
        return bodyShapeModel.dresses;
      case 'indian':
        return bodyShapeModel.indian;
      default:
        return [];
    }
  }

  /// Returns outfit recommendations based on body shape string and category
  static List<String> getOutfitRecommendationsFromString({
    required String bodyShapeString,
    required String category,
  }) {
    final bodyShape = _getBodyShapeFromString(bodyShapeString);
    if (bodyShape == null) return [];

    return getOutfitRecommendations(bodyShape: bodyShape, category: category);
  }

  /// Returns all outfit recommendations for a body shape
  static Map<String, List<String>> getAllOutfitRecommendations({
    required BodyShapeOption bodyShape,
  }) {
    final bodyShapeModel = BodyShapeData.getBodyShape(bodyShape);
    if (bodyShapeModel == null) return {};

    return {
      'tops': bodyShapeModel.tops,
      'bottoms': bodyShapeModel.bottoms,
      'dresses': bodyShapeModel.dresses,
      'indian': bodyShapeModel.indian,
    };
  }

  /// Returns all outfit recommendations for a body shape string
  static Map<String, List<String>> getAllOutfitRecommendationsFromString({
    required String bodyShapeString,
  }) {
    final bodyShape = _getBodyShapeFromString(bodyShapeString);
    if (bodyShape == null) return {};

    return getAllOutfitRecommendations(bodyShape: bodyShape);
  }

  /// Returns color recommendations based on undertone and color category
  static Map<String, List<Map<String, dynamic>>> getColorRecommendations({
    required SkinUndertone undertone,
  }) {
    final undertoneModel = SkinUndertoneData.getUndertone(undertone);
    if (undertoneModel == null) return {};

    return {
      'brights': undertoneModel.brights
          .map((color) => {'color': color.color, 'name': color.name})
          .toList(),
      'jewelTones': undertoneModel.jewelTones
          .map((color) => {'color': color.color, 'name': color.name})
          .toList(),
      'softs': undertoneModel.softs
          .map((color) => {'color': color.color, 'name': color.name})
          .toList(),
      'neutrals': undertoneModel.neutrals
          .map((color) => {'color': color.color, 'name': color.name})
          .toList(),
    };
  }

  /// Returns color recommendations based on undertone string
  static Map<String, List<Map<String, dynamic>>>
  getColorRecommendationsFromString({required String undertoneString}) {
    final undertone = _getUndertoneFromString(undertoneString);
    if (undertone == null) return {};

    return getColorRecommendations(undertone: undertone);
  }

  /// Returns colors for a specific category
  static List<Map<String, dynamic>> getColorsForCategory({
    required SkinUndertone undertone,
    required String category, // 'brights', 'jewelTones', 'softs', 'neutrals'
  }) {
    final colors = getColorRecommendations(undertone: undertone);
    return colors[category] ?? [];
  }

  /// Returns colors for a specific category using string undertone
  static List<Map<String, dynamic>> getColorsForCategoryFromString({
    required String undertoneString,
    required String category,
  }) {
    final undertone = _getUndertoneFromString(undertoneString);
    if (undertone == null) return [];

    return getColorsForCategory(undertone: undertone, category: category);
  }

  /// Returns body shape display name and SVG asset
  static Map<String, String> getBodyShapeInfo(BodyShapeOption bodyShape) {
    final bodyShapeModel = BodyShapeData.getBodyShape(bodyShape);
    if (bodyShapeModel == null) {
      return {'name': 'Unknown', 'svgAsset': ''};
    }

    return {'name': bodyShapeModel.name, 'svgAsset': bodyShapeModel.svgAsset};
  }

  /// Returns body shape display name and SVG asset from string
  static Map<String, String> getBodyShapeInfoFromString(
    String bodyShapeString,
  ) {
    final bodyShape = _getBodyShapeFromString(bodyShapeString);
    if (bodyShape == null) {
      return {'name': 'Unknown', 'svgAsset': ''};
    }

    return getBodyShapeInfo(bodyShape);
  }

  /// Returns undertone display name and description
  static Map<String, String> getUndertoneInfo(SkinUndertone undertone) {
    final undertoneModel = SkinUndertoneData.getUndertone(undertone);
    if (undertoneModel == null) {
      return {'name': 'Unknown', 'description': 'Unknown\nundertone.'};
    }

    return {
      'name': undertoneModel.name,
      'description': undertoneModel.description,
    };
  }

  /// Returns undertone display name and description from string
  static Map<String, String> getUndertoneInfoFromString(
    String undertoneString,
  ) {
    final undertone = _getUndertoneFromString(undertoneString);
    if (undertone == null) {
      return {'name': 'Unknown', 'description': 'Unknown\nundertone.'};
    }

    return getUndertoneInfo(undertone);
  }

  /// Complete style analysis - returns everything needed for the UI (using enums)
  static Map<String, dynamic> getCompleteStyleAnalysis({
    required BodyShapeOption bodyShape,
    required SkinUndertone undertone,
  }) {
    return {
      'bodyShape': getBodyShapeInfo(bodyShape),
      'undertone': getUndertoneInfo(undertone),
      'outfits': getAllOutfitRecommendations(bodyShape: bodyShape),
      'colors': getColorRecommendations(undertone: undertone),
    };
  }

  /// Complete style analysis - returns everything needed for the UI (using strings)
  static Map<String, dynamic> getCompleteStyleAnalysisFromStrings({
    required String bodyShapeString,
    required String undertoneString,
  }) {
    final bodyShape = _getBodyShapeFromString(bodyShapeString);
    final undertone = _getUndertoneFromString(undertoneString);

    // Return empty/default data if conversion fails
    if (bodyShape == null || undertone == null) {
      return {
        'bodyShape': {'name': 'Unknown', 'svgAsset': ''},
        'undertone': {'name': 'Unknown', 'description': 'Unknown\nundertone.'},
        'outfits': <String, List<String>>{},
        'colors': <String, List<Map<String, dynamic>>>{},
      };
    }

    return getCompleteStyleAnalysis(bodyShape: bodyShape, undertone: undertone);
  }
}
