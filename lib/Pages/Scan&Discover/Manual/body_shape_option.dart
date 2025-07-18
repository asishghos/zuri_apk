import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/services/Class/result_class.dart';

class BodyShape {
  final String id;
  final String name;
  final String description;
  final String svgPath;

  const BodyShape({
    required this.id,
    required this.name,
    required this.description,
    required this.svgPath,
  });
}

class BodyShapeSelector extends StatefulWidget {
  const BodyShapeSelector({Key? key}) : super(key: key);

  @override
  State<BodyShapeSelector> createState() => _BodyShapeSelectorState();
}

class _BodyShapeSelectorState extends State<BodyShapeSelector> {
  String? _selectedShapeId;

  final List<BodyShape> _bodyShapes = const [
    BodyShape(
      id: 'hourglass',
      name: 'Hourglass',
      description:
          'Your bust and hips are in sync, with a gorgeously defined waist in between.',
      svgPath: 'assets/images/body_shape/hour_glass.svg',
    ),
    BodyShape(
      id: 'pear',
      name: 'Pear',
      description:
          'Your hips steal the spotlight, with a smaller bust and defined waist.',
      svgPath: 'assets/images/body_shape/pear.svg',
    ),
    BodyShape(
      id: 'apple',
      name: 'Apple',
      description:
          'You have a fuller bust and midsection, with slimmer legs and narrower hips.',
      svgPath: 'assets/images/body_shape/apple.svg',
    ),
    BodyShape(
      id: 'rectangle',
      name: 'Rectangle',
      description:
          'You have balanced shoulders, waist, and hips with minimal curves.',
      svgPath: 'assets/images/body_shape/rectangle.svg',
    ),
    BodyShape(
      id: 'invertedTriangle',
      name: 'Inverted Triangle',
      description:
          'You have relatively broader shoulders, narrower hips, and a softly defined waist.',
      svgPath: 'assets/images/body_shape/inverted triangle.svg',
    ),
  ];

  void _selectAndNavigate(String shapeId) {
    setState(() {
      _selectedShapeId = shapeId;
    });
    // Navigate after a short delay to show selection feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.goNamed(
          'quiz',
          queryParameters: {
            "body_shape": _bodyShapes
                .firstWhere((shape) => shape.id == shapeId)
                .id,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          itemCount: _bodyShapes.length,
          itemBuilder: (context, index) {
            final shape = _bodyShapes[index];
            final isSelected = shape.id == _selectedShapeId;
            return GestureDetector(
              onTap: () => _selectAndNavigate(shape.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(6),
                height: MediaQuery.of(context).size.height * 0.13,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? const Color(0xFFFBD1D4)
                      : const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFFD34169), width: 1),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 16),
                      child: SvgPicture.asset(
                        shape.svgPath,
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.018306636,
                          ),
                          Text(
                            shape.name,
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD34169),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            shape.description,
                            style: GoogleFonts.libreFranklin(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.black
                                  : Color(0xFF979797),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
