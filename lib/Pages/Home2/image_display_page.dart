// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:testing2/services/Class/generate_image_model.dart';

// class ImageDisplayPage extends StatefulWidget {
//   final GenerateImageClass result;
//   final String? clothingType;
//   final String? occasion;
//   final File? originalImage;

//   const ImageDisplayPage({
//     Key? key,
//     required this.result,
//     required this.clothingType,
//     required this.occasion,
//     required this.originalImage,
//   }) : super(key: key);

//   @override
//   State<ImageDisplayPage> createState() => _ImageDisplayPageState();
// }

// class _ImageDisplayPageState extends State<ImageDisplayPage>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Widget _buildBase64Image(
//     String base64String, {
//     BoxFit fit = BoxFit.contain,
//     double? width,
//     double? height,
//   }) {
//     try {
//       // Remove data:image/jpeg;base64, prefix if present
//       String cleanBase64 = base64String;
//       if (base64String.contains(',')) {
//         cleanBase64 = base64String.split(',')[1];
//       }

//       Uint8List bytes = base64Decode(cleanBase64);
//       return Image.memory(
//         bytes,
//         fit: fit,
//         width: width,
//         height: height,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             width: width,
//             height: height,
//             color: Color(0xFFFFD6D5),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.broken_image, size: 60, color: Color(0xFF8D6E63)),
//                 SizedBox(height: 12),
//                 Text(
//                   'Failed to load image',
//                   style: TextStyle(color: Color(0xFF5D4037), fontSize: 14),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       return Container(
//         width: width,
//         height: height,
//         color: Color(0xFFFFD6D5),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error, size: 60, color: Color(0xFF8D6E63)),
//             SizedBox(height: 12),
//             Text(
//               'Invalid image data',
//               style: TextStyle(color: Color(0xFF5D4037), fontSize: 14),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFEEEED),
//       appBar: AppBar(
//         backgroundColor: Color(0xFFF8BBB9),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Your Style Match',
//           style: TextStyle(
//             color: Color(0xFF5D4037),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               if (widget.clothingType != null || widget.occasion != null)
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF8BBB9),
//                     borderRadius: BorderRadius.circular(32),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFFCBA6A5).withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       if (widget.clothingType != null) ...[
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF5D4037),
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Text(
//                             widget.clothingType!,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                       ],
//                       if (widget.occasion != null)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF8D6E63),
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Text(
//                             widget.occasion!,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//               SizedBox(height: 30),

//               // Original Image Section (if provided)
//               if (widget.originalImage != null) ...[
//                 Text(
//                   'Your Original Image',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF5D4037),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFFCBA6A5).withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.file(
//                       widget.originalImage!,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//               ],

//               // Recommended Style Title
//               Text(
//                 'Recommended Style',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF5D4037),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Single Image Display
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(32),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color(0xFFCBA6A5).withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(32),
//                   child: _buildBase64Image(
//                     widget.result.results[0].base64,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 30),

//               // Action Buttons
//               Column(
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Handle save favorites or similar action
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Style saved to favorites!'),
//                             backgroundColor: Color(0xFF5D4037),
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 18),
//                         backgroundColor: Color(0xFFF8BBB9),
//                         foregroundColor: Color(0xFF5D4037),
//                         elevation: 8,
//                         shadowColor: Color(0xFFCBA6A5).withOpacity(0.3),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(32),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.favorite, size: 22),
//                           SizedBox(width: 10),
//                           Text(
//                             'Save to Favorites',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Container(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: OutlinedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 18),
//                         foregroundColor: Color(0xFF5D4037),
//                         side: BorderSide(color: Color(0xFF8D6E63), width: 2),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(32),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.upload_file, size: 22),
//                           SizedBox(width: 10),
//                           Text(
//                             'Try Another Image',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Updated Navigation Helper for Base64 images
// class NavigationHelper {
//   static void navigateToImageDisplay(
//     BuildContext context, {
//     required GenerateImageClass result,
//     String? clothingType,
//     String? occasion,
//     File? originalImage,
//   }) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ImageDisplayPage(
//           result: result,
//           clothingType: clothingType,
//           occasion: occasion,
//           originalImage: originalImage,
//         ),
//       ),
//     );
//   }
// }
