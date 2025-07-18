import 'dart:developer' as Developer;
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Wardrobe/CreateOutfits/clothing_selection_popup.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';

class UploadOutfitPage extends StatefulWidget {
  final bool? isDialogBoxOpen;
  final String? occasion;
  final String? description;
  final String? eventId;
  final String? loaction;
  final String? dayEventId;
  UploadOutfitPage({
    super.key,
    this.isDialogBoxOpen,
    this.occasion,
    this.description,
    this.eventId,
    this.loaction,
    this.dayEventId,
  });
  @override
  _UploadOutfitPageState createState() => _UploadOutfitPageState();
}

class _UploadOutfitPageState extends State<UploadOutfitPage> {
  bool hasTopUploaded = false;
  bool hasBottomUploaded = false;
  bool hasFootwearUploaded = false;
  bool hasAccessoriesUploaded = false;
  File? _topsImage;
  File? _bottomsImage;
  File? _footwearImage;
  File? _accessoriesimage;
  final TextEditingController _occasionController = TextEditingController();
  // Initialize the images list
  late List<File> images = []; // Add = [] here
  late String occasion;

  // Simulate different states for demo
  int currentState = 0; // 0: initial, 1: one item uploaded, 2: ready to style
  @override
  void initState() {
    super.initState();

    // Log all incoming widget data
    Developer.log("isDialogBoxOpen: ${widget.isDialogBoxOpen}");
    Developer.log("occasion: ${widget.occasion}");
    Developer.log("description: ${widget.description}");
    Developer.log("eventId: ${widget.eventId}");
    Developer.log("location: ${widget.loaction}");

    // Set occasion in controller if available
    if (widget.occasion != null && widget.occasion!.isNotEmpty) {
      _occasionController.text = widget.occasion!;
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    context.goNamed('myWardrobe');
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(width: 16),
                // folllow the main _shell app bar style------------------------------------------
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Style me ",
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.titleTextColor,
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "the",
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.textPrimary,
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: " Look!",
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.textPrimary,
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Curate me an outfit for...',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.013729977,
                  ),
                  TextField(
                    controller: _occasionController,
                    decoration: InputDecoration(
                      hintText: "Girl's night out...",
                      hintStyle: GoogleFonts.libreFranklin(
                        color: Colors.grey[400],
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Color(0xFFD87A9B),
                          width:
                              MediaQuery.of(context).size.width * 0.004975124,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          currentState = 0;
                        });
                      }
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0274599,
                  ),
                  Text(
                    '''Drop an item or 2 from your Zuri closet or Phone gallery—I'll work my magic around it.''',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.46,
                    child: _buildCategoryGrid(),
                  ),
                  _buildActionButton(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Replace your existing _buildCategoryCard method with this updated version

  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildCategoryCard('Tops', _topsImage != null, () async {
          final result = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(builder: (context) => ClothingSelectionPopup()),
          );
          if (result != null) {
            File imageFile;
            if (result is GarmentItem) {
              // If result is GarmentItem, convert URL to File
              imageFile = await GlobalFunction.urlToFile(result.imageUrl);
            } else if (result is File) {
              // If result is File, use it directly
              imageFile = result;
            } else {
              // Handle unexpected type
              Developer.log('Unexpected result type: ${result.runtimeType}');
              return;
            }
            if (_occasionController.text.isNotEmpty) {
              currentState = 1;
            } else {
              currentState = 2;
            }
            images.add(imageFile);

            setState(() {
              _topsImage = imageFile;
              hasTopUploaded = true;
            });
            Developer.log('Tops image path: ${_topsImage!.path}');
          }
        }),

        _buildCategoryCard('Bottoms', _bottomsImage != null, () async {
          final result = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(builder: (context) => ClothingSelectionPopup()),
          );
          if (result != null) {
            File imageFile;
            if (result is GarmentItem) {
              imageFile = await GlobalFunction.urlToFile(result.imageUrl);
            } else if (result is File) {
              imageFile = result;
            } else {
              Developer.log('Unexpected result type: ${result.runtimeType}');
              return;
            }
            if (_occasionController.text.isNotEmpty) {
              currentState = 1;
            } else {
              currentState = 2;
            }
            images.add(imageFile);
            setState(() {
              _bottomsImage = imageFile;
              hasBottomUploaded = true; // Fixed: was hasTopUploaded
            });
            Developer.log('Bottoms image path: ${_bottomsImage!.path}');
          }
        }),

        _buildCategoryCard('Footwear', _footwearImage != null, () async {
          final result = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(builder: (context) => ClothingSelectionPopup()),
          );
          if (result != null) {
            File imageFile;
            if (result is GarmentItem) {
              imageFile = await GlobalFunction.urlToFile(result.imageUrl);
            } else if (result is File) {
              imageFile = result;
            } else {
              Developer.log('Unexpected result type: ${result.runtimeType}');
              return;
            }
            if (_occasionController.text.isNotEmpty) {
              currentState = 1;
            } else {
              currentState = 2;
            }
            images.add(imageFile);
            setState(() {
              _footwearImage = imageFile;
              hasFootwearUploaded = true; // Fixed: was hasTopUploaded
            });
            Developer.log('Footwear image path: ${_footwearImage!.path}');
          }
        }),

        _buildCategoryCard('Accessories', _accessoriesimage != null, () async {
          final result = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(builder: (context) => ClothingSelectionPopup()),
          );
          if (result != null) {
            File imageFile;
            if (result is GarmentItem) {
              imageFile = await GlobalFunction.urlToFile(result.imageUrl);
            } else if (result is File) {
              imageFile = result;
            } else {
              Developer.log('Unexpected result type: ${result.runtimeType}');
              return;
            }
            if (_occasionController.text.isNotEmpty) {
              currentState = 1;
            } else {
              currentState = 2;
            }
            images.add(imageFile);

            setState(() {
              _accessoriesimage = imageFile;
              hasAccessoriesUploaded = true; // Fixed: was hasTopUploaded
            });
            Developer.log('Accessories image path: ${_accessoriesimage!.path}');
          }
        }),
      ],
    );
  }

  Widget _buildCategoryCard(String title, bool hasImage, VoidCallback onTap) {
    File? image;
    switch (title) {
      case 'Tops':
        image = _topsImage;
        break;
      case 'Bottoms':
        image = _bottomsImage;
        break;
      case 'Footwear':
        image = _footwearImage;
        break;
      case 'Accessories':
        image = _accessoriesimage;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: [5, 5],
          radius: Radius.circular(32),
          color: Color(0xFFE25C7E),
          padding: EdgeInsets.all(0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: hasImage ? Color(0xFFFFE0EC) : Color(0xFFF9FAFB),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      // Mock image - replace with actual image
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: hasImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: image != null
                                          ? Image.file(
                                              image,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return _buildPlaceholder(
                                                      title,
                                                    );
                                                  },
                                            )
                                          : _buildPlaceholder(title),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedAdd01,
                                      color: AppColors.textPrimary,
                                      size: 40,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.013729977,
                                    ),
                                    Text(
                                      title,
                                      style: GoogleFonts.libreFranklin(
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(14),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.titleTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),
                      Text(
                        title,
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      color: Color(0xFFFFE0EC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.199,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.libreFranklin(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
            Text(
              title,
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    bool hasAnyItem =
        (hasTopUploaded ||
            hasBottomUploaded ||
            hasFootwearUploaded ||
            hasAccessoriesUploaded) &&
        _occasionController.text.isNotEmpty;

    return GlobalPinkButton(
      text: _getButtonText(),
      fontSize: MediaQuery.of(context).textScaler.scale(16),
      onPressed: hasAnyItem
          ? () {
              currentState = 1;
              final extraData = <String, dynamic>{};

              if (widget.occasion != null && widget.occasion!.isNotEmpty)
                extraData["occasion"] = widget.occasion;
              if (widget.description != null && widget.description!.isNotEmpty)
                extraData["description"] = widget.description;
              if (widget.eventId != null && widget.eventId!.isNotEmpty)
                extraData["eventId"] = widget.eventId;
              if (widget.loaction != null && widget.loaction!.isNotEmpty)
                extraData["location"] = widget.loaction;
              if (widget.dayEventId != null && widget.dayEventId!.isNotEmpty)
                extraData["dayEventId"] = widget.dayEventId;
              if (extraData.isNotEmpty) {
                extraData["isDialogBoxOpen"] = true;
              }

              context.goNamed(
                'createOutfit',
                queryParameters: {
                  "occasion": _occasionController.text,
                  "imagePaths": images.map((file) => file.path).join(','),
                },
                extra: extraData.isNotEmpty ? extraData : null,
              );
              Developer.log("data come on this page .. create outfit page ");
            }
          : () {},
      backgroundColor: hasAnyItem ? Color(0xFFE25C7E) : Color(0xFFE5E7EA),
      foregroundColor: hasAnyItem ? Colors.white : Color(0xFF9EA2AE),
    );
  }

  String _getButtonText() {
    bool hasAnyItem =
        hasTopUploaded ||
        hasBottomUploaded ||
        hasFootwearUploaded ||
        hasAccessoriesUploaded;
    bool hasOccasion = _occasionController.text.trim().isNotEmpty;

    if (!hasAnyItem) {
      return 'Upload at least one item to get started!';
    } else if (hasAnyItem && !hasOccasion) {
      return 'Add your occasion to let Zuri style you!';
    } else {
      return 'Done uploading? Let\'s style!';
    }
  }
}
