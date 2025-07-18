// class StyleResult {
//   final String style;
//   final String base64;

//   StyleResult({required this.style, required this.base64});

//   factory StyleResult.fromJson(Map<String, dynamic> json) {
//     return StyleResult(
//       style: json['style'] as String,
//       base64: json['base64'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'style': style, 'base64': base64};
//   }
// }

// class GenerateImageClass {
//   final List<StyleResult> results;

//   GenerateImageClass({required this.results});

//   factory GenerateImageClass.fromJson(Map<String, dynamic> json) {
//     return GenerateImageClass(
//       results:
//           (json['results'] as List<dynamic>)
//               .map((e) => StyleResult.fromJson(e as Map<String, dynamic>))
//               .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'results': results.map((e) => e.toJson()).toList()};
//   }
// }
