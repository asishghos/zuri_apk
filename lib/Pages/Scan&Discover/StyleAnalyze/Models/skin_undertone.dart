// models/skin_undertone.dart
import 'package:flutter/material.dart';

enum SkinUndertone { cool, warm, neutral }

class ColorPalette {
  final String name;
  final Color color;

  const ColorPalette({required this.name, required this.color});
}

class UndertoneModel {
  final SkinUndertone undertone;
  final String name;
  final String description;
  final List<ColorPalette> brights;
  final List<ColorPalette> jewelTones;
  final List<ColorPalette> softs;
  final List<ColorPalette> neutrals;

  const UndertoneModel({
    required this.undertone,
    required this.name,
    required this.description,
    required this.brights,
    required this.jewelTones,
    required this.softs,
    required this.neutrals,
  });
}

class SkinUndertoneData {
  static const Map<SkinUndertone, UndertoneModel> undertones = {
    SkinUndertone.cool: UndertoneModel(
      undertone: SkinUndertone.cool,
      name: 'Cool',
      description: 'Cool\nundertone.',
      brights: [
        ColorPalette(name: 'Royal Blue', color: Color(0xFF4169E1)),
        ColorPalette(name: 'Magenta', color: Color(0xFFFF00FF)),
        ColorPalette(name: 'Emerald', color: Color(0xFF50C878)),
        ColorPalette(name: 'True Red', color: Color(0xFFFF0000)),
      ],
      jewelTones: [
        ColorPalette(name: 'Sapphire\nBlue', color: Color(0xFF0F52BA)),
        ColorPalette(name: 'Amethyst\nPurple', color: Color(0xFF9966CC)),
        ColorPalette(name: 'Emerald\nGreen', color: Color(0xFF228B22)),
        ColorPalette(name: 'Ruby\nRed', color: Color(0xFFE0115F)),
      ],
      softs: [
        ColorPalette(name: 'Lavender', color: Color(0xFFE6E6FA)),
        ColorPalette(name: 'Baby Blue', color: Color(0xFF89CFF0)),
        ColorPalette(name: 'Mint Green', color: Color(0xFF98FB98)),
        ColorPalette(name: 'Rose Pink', color: Color(0xFFFF66CC)),
      ],
      neutrals: [
        ColorPalette(name: 'Charcoal', color: Color(0xFF36454F)),
        ColorPalette(name: 'Navy', color: Color(0xFF000080)),
        ColorPalette(name: 'Pure White', color: Color(0xFFFFFFFF)),
        ColorPalette(name: 'Silver Grey', color: Color(0xFFC0C0C0)),
      ],
    ),
    SkinUndertone.warm: UndertoneModel(
      undertone: SkinUndertone.warm,
      name: 'Warm',
      description: 'Warm\nundertone.',
      brights: [
        ColorPalette(name: 'Orange', color: Color(0xFFFF8C00)),
        ColorPalette(name: 'Golden Yellow', color: Color(0xFFFFD700)),
        ColorPalette(name: 'Coral', color: Color(0xFFFF7F50)),
        ColorPalette(name: 'Turquoise', color: Color(0xFF40E0D0)),
      ],
      jewelTones: [
        ColorPalette(name: 'Golden\nTopaz', color: Color(0xFFFFC87C)),
        ColorPalette(name: 'Amber\nOrange', color: Color(0xFFFF8000)),
        ColorPalette(name: 'Olive\nGreen', color: Color(0xFF808000)),
        ColorPalette(name: 'Burnt\nSienna', color: Color(0xFFE97451)),
      ],
      softs: [
        ColorPalette(name: 'Peach', color: Color(0xFFFFDAB9)),
        ColorPalette(name: 'Cream', color: Color(0xFFFFFDD0)),
        ColorPalette(name: 'Soft Coral', color: Color(0xFFF88379)),
        ColorPalette(name: 'Warm Beige', color: Color(0xFFF5F5DC)),
      ],
      neutrals: [
        ColorPalette(name: 'Chocolate', color: Color(0xFFD2691E)),
        ColorPalette(name: 'Camel', color: Color(0xFFC19A6B)),
        ColorPalette(name: 'Ivory', color: Color(0xFFFFFFF0)),
        ColorPalette(name: 'Warm Grey', color: Color(0xFF8B8680)),
      ],
    ),
    SkinUndertone.neutral: UndertoneModel(
      undertone: SkinUndertone.neutral,
      name: 'Neutral',
      description: 'Neutral\nundertone.',
      brights: [
        ColorPalette(name: 'Fuschia', color: Color(0xFFE25C7E)),
        ColorPalette(name: 'Mustard', color: Color(0xFFB8860B)),
        ColorPalette(name: 'Teal', color: Color(0xFF008B8B)),
        ColorPalette(name: 'Tomato Red', color: Color(0xFFFF6347)),
      ],
      jewelTones: [
        ColorPalette(name: 'Emerald\nGreen', color: Color(0xFF228B22)),
        ColorPalette(name: 'Deep Ruby', color: Color(0xFF8B0000)),
        ColorPalette(name: 'Royal\nPurple', color: Color(0xFF663399)),
        ColorPalette(name: 'Sapphire\nBlue', color: Color(0xFF1E90FF)),
      ],
      softs: [
        ColorPalette(name: 'Peach', color: Color(0xFFFFDAB9)),
        ColorPalette(name: 'Terracota', color: Color(0xFFCD853F)),
        ColorPalette(name: 'Blush', color: Color(0xFFDE3163)),
        ColorPalette(name: 'Ivory', color: Color(0xFFFFFFF0)),
      ],
      neutrals: [
        ColorPalette(name: 'Camel', color: Color(0xFFC19A6B)),
        ColorPalette(name: 'Beige', color: Color(0xFFF5F5DC)),
        ColorPalette(name: 'Taupe', color: Color(0xFF696969)),
        ColorPalette(name: 'Rose Brown', color: Color(0xFF8B4513)),
      ],
    ),
  };

  static UndertoneModel? getUndertone(SkinUndertone undertone) {
    return undertones[undertone];
  }
}
