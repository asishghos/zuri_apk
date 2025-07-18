// pages/style_analysis_page.dart
import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Scan&Discover/StyleAnalyze/style_analyze_service.dart';
import 'package:testing2/services/Class/style_analyze_model.dart';
import 'package:testing2/services/DataSource/style_analysis_api.dart';
import 'package:testing2/services/DataSource/uploaded_look_api.dart';
import 'package:testing2/services/Temp/TempUserDataStore.dart';

class StyleAnalysisPage extends StatefulWidget {
  // final String bodyShape;
  // final String skinUndertone;

  const StyleAnalysisPage({
    Key? key,
    // required this.bodyShape,
    // required this.skinUndertone,
  }) : super(key: key);

  @override
  State<StyleAnalysisPage> createState() => _StyleAnalysisPageState();
}

class _StyleAnalysisPageState extends State<StyleAnalysisPage> {
  Map<String, dynamic>? styleAnalysis;
  StyleAnalyzeClass? response;
  bool _isLoading = true;
  SharedPreferences? prefs;
  List<String>? _keywords;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // Background upload method
  void _uploadImageInBackground(File imageFile) {
    // Fire and forget - don't await
    UploadedLooksService.uploadLook(imageFile: imageFile)
        .then((_) {
          Developer.log("Success to upload this picture");
        })
        .catchError((e) {
          Developer.log("Failed to upload this picture: $e");
        });
  }

  Future<void> _initializePage() async {
    setState(() => _isLoading = true);

    try {
      prefs = await SharedPreferences.getInstance();

      final loaded = await TempUserDataStore().load();
      if (!loaded) {
        Developer.log("❌ Data not coming from TempUserDataStore.dart");
        showErrorSnackBar(
          context,
          "Data not coming from TempUserDataStore.dart",
        );
        context.goNamed('home2');
        return;
      }

      Developer.log("BodyShape: ${TempUserDataStore().bodyShape}");
      Developer.log("SkinTone: ${TempUserDataStore().skinTone}");
      Developer.log("ImageFile: ${TempUserDataStore().imageFile}");

      // Fetch style analysis
      if (TempUserDataStore().imageFile == null) {
        response = await StyleAnalyzeApiService.manualAanalyzeservice(
          TempUserDataStore().bodyShape ?? '',
          TempUserDataStore().skinTone ?? '',
        );
      } else {
        response = await StyleAnalyzeApiService.autoAanalyzeservice(
          TempUserDataStore().imageFile!,
        );
        _uploadImageInBackground(TempUserDataStore().imageFile!);
      }

      // Save to shared prefs
      await prefs!.setString(
        "bodyShape",
        response!.bodyShapeResult?.bodyShape ?? '',
      );
      await prefs!.setString(
        "skinTone",
        response!.bodyShapeResult?.skinTone ?? '',
      );

      // Prepare complete styleAnalysis
      styleAnalysis = StyleAnalysisService.getCompleteStyleAnalysisFromStrings(
        bodyShapeString: response!.bodyShapeResult?.bodyShape ?? '',
        undertoneString: response!.bodyShapeResult?.skinTone ?? '',
      );

      // Fetch keywords based on updated prefs
      await _fetchKeywords();

      // Clear temp store
      TempUserDataStore().clear();
    } catch (e, stackTrace) {
      Developer.log(
        "🔥 Error during init: $e",
        error: e,
        stackTrace: stackTrace,
      );
      showErrorSnackBar(context, "Something went wrong. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchKeywords() async {
    try {
      final result = await GlobalFunction.findKeywordsUserSpecific(
        prefs?.getString("bodyShape") ?? "Apple",
        prefs?.getString("skinTone") ?? "Neutral",
      );
      _keywords = result;
    } catch (e) {
      showErrorSnackBar(context, "Failed to fetch user-based keywords");
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    if (_isLoading) {
      return LoadingPage();
    }
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
          Container(
            child: Text(
              'Your true tone + unique body type',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(24),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: response == null
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Your body type',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(20),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.018306636,
                                ),
                                Container(
                                  height: dh * 0.22,
                                  width: dw * 0.44,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.textPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      // Body Shape Icon
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.199,
                                        height: 100,
                                        child: SvgPicture.asset(
                                          styleAnalysis?['bodyShape']['svgAsset'],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        styleAnalysis?['bodyShape']['name'],
                                        style: GoogleFonts.libreFranklin(
                                          fontSize: MediaQuery.of(
                                            context,
                                          ).textScaler.scale(18),
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
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(20),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.018306636,
                                ),
                                Container(
                                  height: dh * 0.22,
                                  width: dw * 0.44,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.textPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      styleAnalysis?['undertone']['description'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.libreFranklin(
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(18),
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

                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.0343249,
                        ),

                        // Colors Section
                        Text(
                          'Colors that love you most!',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(20),
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.022883295,
                        ),

                        // Dynamic Color Sections
                        _buildColorSection(
                          'Brights',
                          dh,
                          dw,
                          styleAnalysis?['colors']['brights'],
                        ),
                        _buildColorSection(
                          'Jewel\nTone',
                          dh,
                          dw,
                          styleAnalysis?['colors']['jewelTones'],
                        ),
                        _buildColorSection(
                          'Softs',
                          dh,
                          dw,
                          styleAnalysis?['colors']['softs'],
                        ),
                        _buildColorSection(
                          'Neutrals',
                          dh,
                          dw,
                          styleAnalysis?['colors']['neutrals'],
                        ),

                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.036613272,
                        ),

                        // Outfits Section
                        Text(
                          'Outfits that gives you Va-Va-Voom Vibes!',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(20),
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.022883295,
                        ),

                        // Dynamic Outfit Categories
                        _buildOutfitCard(
                          'Tops',
                          dh,
                          dw,
                          "assets/images/styleanalysis/s1.svg",
                          styleAnalysis?['outfits']['tops'],
                        ),
                        _buildOutfitCard(
                          'Bottoms',
                          dh,
                          dw,
                          "assets/images/styleanalysis/s2.svg",
                          styleAnalysis?['outfits']['bottoms'],
                        ),
                        _buildOutfitCard(
                          'Dresses',
                          dh,
                          dw,
                          "assets/images/styleanalysis/s3.svg",
                          styleAnalysis?['outfits']['dresses'],
                        ),
                        _buildOutfitCard(
                          'Indian',
                          dh,
                          dw,
                          "assets/images/styleanalysis/s5.svg",
                          styleAnalysis?['outfits']['indian'],
                        ),

                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.0274599,
                        ),

                        // Call to Action
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Want Zuri to fetch you fresh outfit inspos based on your cuts & colors?',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(18),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.022883295,
                              ),
                              GlobalPinkButton(
                                text: "Yes! Can't wait to see what's in store!",
                                onPressed: () {
                                  final stringKeywords = (_keywords as List)
                                      .cast<String>()
                                      .join(',');
                                  context.goNamed(
                                    'affiliate',
                                    queryParameters: {
                                      'keywords': stringKeywords,
                                      'needToOpenAskZuri': "false",
                                    },
                                  );
                                },
                                isLoading: _isLoading,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.018306636,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                fontSize: MediaQuery.of(context).textScaler.scale(18),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
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
            height: dh * 0.1,
            width: dw * 0.25,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white),
            child: SvgPicture.asset(svgPath),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.049751243),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(18),
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
            Text(
              'Failed to generate looks',
              style: GoogleFonts.libreFranklin(
                color: Colors.red,
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
            ElevatedButton(
              onPressed: () {
                _initializePage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.libreFranklin(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
