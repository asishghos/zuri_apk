class BodyShapeResult {
  String? bodyShape;
  String? skinTone;

  BodyShapeResult({this.bodyShape, this.skinTone});

  BodyShapeResult.fromJson(Map<String, dynamic> json) {
    bodyShape = json['bodyShape'];
    skinTone = json['skinTone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['bodyShape'] = bodyShape;
    data['skinTone'] = skinTone;
    return data;
  }
}

class StyleAnalyzeClass {
  BodyShapeResult? bodyShapeResult;

  StyleAnalyzeClass({this.bodyShapeResult});

  StyleAnalyzeClass.fromJson(Map<String, dynamic> json) {
    bodyShapeResult =
        json['bodyShapeResult'] != null
            ? BodyShapeResult?.fromJson(json['bodyShapeResult'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['bodyShapeResult'] = bodyShapeResult!.toJson();
    return data;
  }
}
