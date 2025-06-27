// pages/style_analysis_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Scan&Discover/StyleAnalyze/style_analyze_service.dart';

class StyleAnalysisPage extends StatefulWidget {
  final String bodyShape;
  final String skinUndertone;

  const StyleAnalysisPage({
    Key? key,
    required this.bodyShape,
    required this.skinUndertone,
  }) : super(key: key);

  @override
  State<StyleAnalysisPage> createState() => _StyleAnalysisPageState();
}

class _StyleAnalysisPageState extends State<StyleAnalysisPage> {
  late Map<String, dynamic> styleAnalysis;

  @override
  void initState() {
    super.initState();
    // Get complete style analysis based on body shape and undertone
    styleAnalysis = StyleAnalysisService.getCompleteStyleAnalysisFromStrings(
      bodyShapeString: widget.bodyShape,
      undertoneString: widget.skinUndertone,
    );
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Type Analysis Section
          Text(
            'Your true tone + unique body type',
            style: GoogleFonts.libreFranklin(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 32),

          // Body Type and Skin Undertone Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Your body type',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: dh * 0.22,
                    width: dw * 0.44,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textPrimary),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        // Body Shape Icon
                        Container(
                          width: 80,
                          height: 100,
                          child: SvgPicture.asset(
                            styleAnalysis['bodyShape']['svgAsset'],
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          styleAnalysis['bodyShape']['name'],
                          style: GoogleFonts.libreFranklin(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Skin undertone',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: dh * 0.22,
                    width: dw * 0.44,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textPrimary),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        styleAnalysis['undertone']['description'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 30),

          // Colors Section
          Text(
            'Colors that love you most!',
            style: GoogleFonts.libreFranklin(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.titleTextColor,
            ),
          ),
          SizedBox(height: 20),

          // Dynamic Color Sections
          _buildColorSection(
            'Brights',
            dh,
            dw,
            styleAnalysis['colors']['brights'],
          ),
          _buildColorSection(
            'Jewel\nTone',
            dh,
            dw,
            styleAnalysis['colors']['jewelTones'],
          ),
          _buildColorSection('Softs', dh, dw, styleAnalysis['colors']['softs']),
          _buildColorSection(
            'Neutrals',
            dh,
            dw,
            styleAnalysis['colors']['neutrals'],
          ),

          SizedBox(height: 32),

          // Outfits Section
          Text(
            'Outfits that gives you Va-Va-Voom Vibes!',
            style: GoogleFonts.libreFranklin(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.titleTextColor,
            ),
          ),
          SizedBox(height: 20),

          // Dynamic Outfit Categories
          _buildOutfitCard(
            'Tops',
            dh,
            dw,
            "assets/images/styleanalysis/s1.svg",
            styleAnalysis['outfits']['tops'],
          ),
          _buildOutfitCard(
            'Bottoms',
            dh,
            dw,
            "assets/images/styleanalysis/s2.svg",
            styleAnalysis['outfits']['bottoms'],
          ),
          _buildOutfitCard(
            'Dresses',
            dh,
            dw,
            "assets/images/styleanalysis/s3.svg",
            styleAnalysis['outfits']['dresses'],
          ),
          _buildOutfitCard(
            'Indian',
            dh,
            dw,
            "assets/images/styleanalysis/s4.svg",
            styleAnalysis['outfits']['indian'],
          ),

          SizedBox(height: 24),

          // Call to Action
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want Zuri to fetch you fresh outfit inspos based on your cuts & colors?',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(height: 20),
                GlobalPinkButton(
                  text: "Yes! Can't wait to see what's in store!",
                  onPressed: () {},
                  rightIcon: true,
                  rightIconData: HugeIcons.strokeRoundedArrowRight01,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(
    String title,
    double dh,
    double dw,
    List<Map<String, dynamic>> colors,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: dw * 0.18,
            child: Text(
              title,
              style: GoogleFonts.libreFranklin(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.titleTextColor,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((colorData) {
                return Column(
                  children: [
                    Container(
                      width: dw * 0.114,
                      height: dh * 0.05377,
                      decoration: BoxDecoration(
                        color: colorData['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      colorData['name'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: AppColors.titleTextColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(
    String title,
    double dh,
    double dw,
    String svgPath,
    List<String> items,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textPrimary),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(svgPath),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Spacer(),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                ...items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          "• $item",
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9EA2AE),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
