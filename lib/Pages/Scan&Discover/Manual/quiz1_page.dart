// import 'dart:developer' as Developer;

// import 'package:flutter/material.dart';
// import 'package:flutter_iconly/flutter_iconly.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:testing2/Global/Widget/global_dialogbox.dart';
// import 'package:testing2/services/Class/result_class.dart';

// class Quiz1Page extends StatefulWidget {
//   final String body_shape;

//   const Quiz1Page({Key? key, required this.body_shape}) : super(key: key);

//   @override
//   _Quiz1PageState createState() => _Quiz1PageState();
// }

// class _Quiz1PageState extends State<Quiz1Page> {
//   int? selectedIndex;

//   final List<SkinTone> skinTones = [
//     SkinTone(
//       title: 'Fair',
//       description: 'The pure peaches and cream complexion.',
//       color: Color(0xFFF5DEB3),
//     ),
//     SkinTone(
//       title: 'Wheatish',
//       description: 'Neutral beige which shines \nwith or without make-up.',
//       color: Color(0xFFDEB887),
//     ),
//     SkinTone(
//       title: 'Tan',
//       description:
//           'Golden or medium brown, perfect \nfor catching the golden hour glow.',
//       color: Color(0xFFCD853F),
//     ),
//     SkinTone(
//       title: 'Deep brown',
//       description:
//           'That skin with the super sheen that \ngives gorg Michelle Obama vibes!',
//       color: Color(0xFF8B4513),
//     ),
//   ];

//   void _selectAndNavigate(int index) {
//     //null safety
//     if (selectedIndex == null) return;
//     if (index < 0 || index >= skinTones.length) return;
//     ResultCache.selectedQuiz1 = skinTones[index].title;

//     Developer.log('Selected skin tone: ${skinTones[index].title}');

//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted) {
//         context.goNamed(
//           "quiz2",
//           queryParameters: {
//             "body_shape": widget.body_shape,
//             "quiz1": skinTones[index].title,
//           },
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // appBar: AppBar(
//       //   actions: [
//       //     TextButton(
//       //       style: TextButton.styleFrom(
//       //         padding: EdgeInsets.zero,
//       //         minimumSize: Size.zero,
//       //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       //       ),
//       //       onPressed: () {
//       //         context.goNamed(
//       //           "quiz2",
//       //           queryParameters: {
//       //             "body_shape": widget.body_shape,
//       //             "quiz1": "skipped",
//       //           },
//       //         );
//       //       },
//       //       child: Text(
//       //         'Skip',
//       //         style: GoogleFonts.libreFranklin(color: Colors.grey[600], fontSize: 16),
//       //       ),
//       //     ),
//       //   ],
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Center(
//               child: Text(
//                 "Pick the swatch that comes closest to your skin. \nNo pressure to be exact, babe.",
//                 style: GoogleFonts.libreFranklin(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.titleTextColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 32),
//             Flexible(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: skinTones.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 18.0),
//                     child: SkinToneCard(
//                       skinTone: skinTones[index],
//                       isSelected: selectedIndex == index,
//                       onTap: () {
//                         setState(() {
//                           selectedIndex = index;
//                         });
//                         _selectAndNavigate(index);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   barrierDismissible: true,
//                   builder: (BuildContext context) {
//                     return GlobalDialogBox(
//                       buttonNeed: false,
//                       title:
//                           "To style you like a ✨, Zuri needs your skin tone + undertone.",
//                       description:
//                           "Why? Because the right shades don’t just match — they glow. \n✨ Think radiant skin, lit-up eyes, and outfits that turn heads. \n🔍 Skin tone sets your base palette. \n🌈 Undertone? It’s the magic that makes golds or silvers pop. \nWe'll recommend outfit + accessory colors that make you look like a vision!😍",
//                     );
//                   },
//                 );
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Why we 10/10 recommend this 3-second quiz?",
//                     style: GoogleFonts.libreFranklin(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.titleTextColor,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Icon(IconlyLight.infoSquare, color: Colors.pink),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             // Optional: Add a continue button that's only enabled when selection is made
//             // Container(
//             //   width: double.infinity,
//             //   height: 56,
//             //   child: ElevatedButton(
//             //     onPressed:
//             //         selectedIndex != null
//             //             ? () => _selectAndNavigate(selectedIndex!)
//             //             : null,
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor:
//             //           selectedIndex != null
//             //               ? Color(0xFFE91E63)
//             //               : Colors.grey[300],
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(28),
//             //       ),
//             //       elevation: 0,
//             //     ),
//             //     child: Text(
//             //       'Continue',
//             //       style: GoogleFonts.libreFranklin(
//             //         color:
//             //             selectedIndex != null ? Colors.white : Colors.grey[600],
//             //         fontSize: 18,
//             //         fontWeight: FontWeight.w500,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SkinTone {
//   final String title;
//   final String description;
//   final Color color;

//   SkinTone({
//     required this.title,
//     required this.description,
//     required this.color,
//   });
// }

// class SkinToneCard extends StatelessWidget {
//   final SkinTone skinTone;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const SkinToneCard({
//     Key? key,
//     required this.skinTone,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18),
//           color: isSelected ? const Color(0xFFFBD1D4) : const Color(0xFFFAFAFA),
//           border: Border.all(
//             color: isSelected ? AppColors.textPrimary : skinTone.color,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 101,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: skinTone.color,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: isSelected ? AppColors.textPrimary : skinTone.color,
//                   width: 1,
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     skinTone.title,
//                     style: GoogleFonts.libreFranklin(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.titleTextColor,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     skinTone.description,
//                     style: GoogleFonts.libreFranklin(
//                       fontSize: 14,
//                       color: Color(0xFF9EA2AE),
//                       height: 1.3,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
