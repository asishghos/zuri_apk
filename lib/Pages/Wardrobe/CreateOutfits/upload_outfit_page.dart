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
                const SizedBox(width: 16),
                // folllow the main _shell app bar style------------------------------------------
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Create ",
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.titleTextColor,
                          fontSize: 16,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Outfit",
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          // fontWeight: FontWeight.w600,
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
                  Text(
                    'Style me For a',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _occasionController,
                    decoration: InputDecoration(
                      hintText: 'Girls night out...',
                      hintStyle: GoogleFonts.libreFranklin(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(
                          color: Color(0xFFD87A9B),
                          width: 2,
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
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Lorem ipsium is a simple dummy text',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.46,
                    child: _buildCategoryGrid(),
                  ),
                  _buildActionButton(),
                  SizedBox(height: 20),
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
                                    const SizedBox(height: 12),
                                    Text(
                                      title,
                                      style: GoogleFonts.libreFranklin(
                                        fontSize: 14,
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
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 14,
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
              width: 80,
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
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.libreFranklin(
                fontSize: 14,
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
        hasTopUploaded &&
        hasBottomUploaded &&
        hasFootwearUploaded &&
        hasAccessoriesUploaded &&
        _occasionController.text.isNotEmpty;

    return GlobalPinkButton(
      text: _getButtonText(),
      onPressed: hasAnyItem
          ? () {
              context.goNamed(
                'createOutfit',
                queryParameters: {
                  "occasion": _occasionController.text,
                  "imagePaths": images
                      .map((file) => file.path)
                      .join(','), // Convert to comma-separated paths
                },
              );
            }
          : () {},
      backgroundColor: hasAnyItem ? Color(0xFFE25C7E) : Color(0xFFE5E7EA),
      foregroundColor: hasAnyItem ? Colors.white : Color(0xFF9EA2AE),
    );
  }

  String _getButtonText() {
    if (currentState == 0) {
      return 'Upload at least one item to get started!';
    } else if (currentState == 1) {
      return 'Done uploading? Let\'s style!';
    } else {
      return 'Add your occasion to let Zuri style you!';
    }
  }
}

// // Demo page to show different states
// class CreateOutfitDemo extends StatefulWidget {
//   @override
//   _CreateOutfitDemoState createState() => _CreateOutfitDemoState();
// }

// class _CreateOutfitDemoState extends State<CreateOutfitDemo> {
//   int currentDemo = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Outfit Demo'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 currentDemo = (currentDemo + 1) % 3;
//               });
//             },
//             child: Text(
//               'Next State',
//               style: GoogleFonts.libreFranklin(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: _buildCurrentState(),
//     );
//   }

//   Widget _buildCurrentState() {
//     return UploadOutfitPageState(initialState: currentDemo);
//   }
// }

// class UploadOutfitPageState extends StatefulWidget {
//   final int initialState;

//   UploadOutfitPageState({required this.initialState});

//   @override
//   _UploadOutfitPageStateState createState() => _UploadOutfitPageStateState();
// }

// class _UploadOutfitPageStateState extends State<UploadOutfitPageState> {
//   late int currentState;

//   @override
//   void initState() {
//     super.initState();
//     currentState = widget.initialState;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: 'Create ',
//                 style: GoogleFonts.libreFranklin(
//                   color: Colors.black,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Outfit',
//                 style: GoogleFonts.libreFranklin(
//                   color: Color(0xFFE91E63),
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Text(
//               'Style me For a',
//               style: GoogleFonts.libreFranklin(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 12),
//             _buildOccasionInput(),
//             SizedBox(height: 24),
//             Text(
//               'Lorem ipsium is a simple dummy text',
//               style: GoogleFonts.libreFranklin(
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(height: 20),
//             _buildCategoryGrid(),
//             SizedBox(height: 20),
//             _buildActionButton(),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOccasionInput() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xFFFFE0EC),
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(color: Color(0xFFE91E63), width: 1),
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: currentState == 2
//               ? "Girls night out..."
//               : "Girls night out ...",
//           hintStyle: GoogleFonts.libreFranklin(
//             color: Colors.black87,
//             fontSize: 14,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//           suffixIcon: Icon(
//             Icons.info_outline,
//             color: Color(0xFFE91E63),
//             size: 20,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid() {
//     return GridView.count(
//       crossAxisCount: 2,
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       childAspectRatio: 0.5,
//       children: [
//         _buildCategoryCard('Tops', currentState >= 1),
//         _buildCategoryCard('Bottoms', false),
//         _buildCategoryCard('Footwear', false),
//         _buildCategoryCard('Accessories', false),
//       ],
//     );
//   }

//   Widget _buildCategoryCard(String title, bool hasImage) {
//     return Container(
//       decoration: BoxDecoration(
//         color: hasImage ? Color(0xFFFFE0EC) : Colors.grey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Color(0xFFE91E63),
//           width: 1,
//           style: BorderStyle.solid,
//         ),
//       ),
//       child: hasImage && title == 'Tops'
//           ? ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 color: Color(0xFFFFE0EC),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'TOP',
//                             style: GoogleFonts.libreFranklin(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         title,
//                         style: GoogleFonts.libreFranklin(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.add, size: 40, color: Color(0xFFE91E63)),
//                 SizedBox(height: 12),
//                 Text(
//                   title,
//                   style: GoogleFonts.libreFranklin(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildActionButton() {
//     return Container(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: currentState == 0 ? null : () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: currentState == 0
//               ? Colors.grey[300]
//               : Color(0xFFE91E63),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25),
//           ),
//           elevation: 0,
//         ),
//         child: Text(
//           _getButtonText(),
//           style: GoogleFonts.libreFranklin(
//             color: currentState == 0 ? Colors.grey[600] : Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   String _getButtonText() {
//     switch (currentState) {
//       case 0:
//         return 'Upload at least one item to get started!';
//       case 1:
//         return 'Done uploading? Let\'s style!';
//       case 2:
//         return 'Add your occasion to let Zuri style you!';
//       default:
//         return 'Upload at least one item to get started!';
//     }
//   }
// }
