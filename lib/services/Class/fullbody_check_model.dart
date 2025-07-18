class ImageCheckClass {
  final bool isFullBody;

  ImageCheckClass({required this.isFullBody});

  factory ImageCheckClass.fromJson(Map<String, dynamic> json) {
    return ImageCheckClass(isFullBody: json['isFullBody'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'isFullBody': isFullBody};
  }
}
