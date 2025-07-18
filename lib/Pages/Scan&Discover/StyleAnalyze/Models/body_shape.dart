// models/body_shape.dart
enum BodyShapeOption { hourglass, apple, pear, rectangle, invertedTriangle }

class BodyShapeModel {
  final BodyShapeOption shape;
  final String name;
  final String svgAsset;
  final List<String> tops;
  final List<String> bottoms;
  final List<String> dresses;
  final List<String> indian;

  const BodyShapeModel({
    required this.shape,
    required this.name,
    required this.svgAsset,
    required this.tops,
    required this.bottoms,
    required this.dresses,
    required this.indian,
  });
}

class BodyShapeData {
  static const Map<BodyShapeOption, BodyShapeModel> bodyShapes = {
    BodyShapeOption.hourglass: BodyShapeModel(
      shape: BodyShapeOption.hourglass,
      name: 'Hour Glass',
      svgAsset: 'assets/images/body_shape/hour_glass.svg',
      tops: ['Peplums', 'Wrap tops', 'Sweetheart necks', 'Scoop & V necks'],
      bottoms: ['High-Waisted Jeans/Trousers', 'Midi Skirts', 'Pencil Skirts'],
      dresses: [
        'A line or Fit & Flare',
        'Wrap Dresses',
        'Sheath & bodycon dress',
      ],
      indian: [
        'Sarees',
        'lehengas',
        'Anarkalis',
        'Kurta sets',
        'Indo-western sets',
      ],
    ),
    BodyShapeOption.apple: BodyShapeModel(
      shape: BodyShapeOption.apple,
      name: 'Apple',
      svgAsset: 'assets/images/body_shape/apple.svg',
      tops: [
        'Empire waist tops',
        'V-neck blouses',
        'Flowy tunics',
        'Off-shoulder tops',
      ],
      bottoms: ['Straight-leg jeans', 'A-line skirts', 'Bootcut trousers'],
      dresses: ['Empire waist dresses', 'A-line dresses', 'Shift dresses'],
      indian: [
        'Anarkali suits',
        'A-line kurtas',
        'Flowy sarees',
        'Palazzo sets',
        'Long kurtis',
      ],
    ),
    BodyShapeOption.pear: BodyShapeModel(
      shape: BodyShapeOption.pear,
      name: 'Pear',
      svgAsset: 'assets/images/body_shape/pear.svg',
      tops: [
        'Boat neck tops',
        'Statement sleeves',
        'Horizontal stripes',
        'Embellished blouses',
      ],
      bottoms: [
        'Dark colored bottoms',
        'Straight-cut pants',
        'Wide-leg trousers',
      ],
      dresses: ['Fit and flare dresses', 'A-line dresses', 'Wrap dresses'],
      indian: [
        'Heavy work blouses',
        'Crop tops with lehengas',
        'Embroidered kurtas',
        'Palazzo suits',
        'Sharara sets',
      ],
    ),
    BodyShapeOption.rectangle: BodyShapeModel(
      shape: BodyShapeOption.rectangle,
      name: 'Rectangle',
      svgAsset: 'assets/images/body_shape/rectangle.svg',
      tops: [
        'Peplum tops',
        'Ruffled blouses',
        'Cropped jackets',
        'Layered tops',
      ],
      bottoms: ['High-waisted jeans', 'Pleated skirts', 'Wide-leg pants'],
      dresses: ['Belted dresses', 'Bodycon dresses', 'Tiered dresses'],
      indian: [
        'Lehengas with crop tops',
        'Peplum kurtas',
        'Sharara suits',
        'Jacket style kurtas',
        'Dhoti pants sets',
      ],
    ),
    BodyShapeOption.invertedTriangle: BodyShapeModel(
      shape: BodyShapeOption.invertedTriangle,
      name: 'Inverted Triangle',
      svgAsset: 'assets/images/body_shape/inverted triangle.svg',
      tops: [
        'Scoop neck tops',
        'Soft fabrics',
        'Minimal details',
        'Straight cut blouses',
      ],
      bottoms: ['Wide-leg pants', 'Flared jeans', 'Pleated skirts'],
      dresses: [
        'A-line dresses',
        'Drop waist dresses',
        'Fit and flare dresses',
      ],
      indian: [
        'Flared lehengas',
        'Palazzo suits',
        'A-line kurtas',
        'Gharara sets',
        'Printed bottom wear',
      ],
    ),
  };

  static BodyShapeModel? getBodyShape(BodyShapeOption shape) {
    return bodyShapes[shape];
  }
}
