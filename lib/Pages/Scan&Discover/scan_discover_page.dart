import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:testing2/services/DataSource/fullbody_check_api.dart';

class ScanDiscoverPage extends StatefulWidget {
  const ScanDiscoverPage({Key? key}) : super(key: key);

  @override
  State<ScanDiscoverPage> createState() => _ScanDiscoverPageState();
}

class _ScanDiscoverPageState extends State<ScanDiscoverPage> {
  @override
  void initState() {
    super.initState();
  }

  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
          _imageFile = File(pickedFile.path);
        });

        final response =
            await FullbodyImageCheckApiServices.fullbodyImageCheckApiServices(
              _imageFile!,
            );
        print(response);
        setState(() {
          _isLoading = false;
        });

        if (response != null && response.isFullBody) {
          context.goNamed('autoUpload', extra: _imageFile);
        } else {
          showDialog(
            context: context,
            barrierDismissible: true, // Prevents closing on tap outside
            builder: (BuildContext context) {
              return GlobalDialogBox(
                title: "Uh Oh!",
                needCancleButton: true,
                buttonNeed: true,
                description:
                    "We can't see your FULL FAB self. Upload head-to-toe pic(s) so we can scan your shape like a pro. Pretty please?",
                buttonText: "Upload Again",
                onTap: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                  _pickAndCheckImage(); // Retry
                },
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error in _pickImage: $e');
    }
  }

  Future<void> _pickAndCheckImage() async {
    _showPicker();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      dashPattern: [5, 5],
                      strokeWidth: 1.64,
                      radius: Radius.circular(32),
                      color: Color(0xFFD34169),
                      padding: EdgeInsets.all(8),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 252, 242, 242),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFE91E63),
                          width: 1.64,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/home1/m1.png'),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _pickAndCheckImage();
                                },
                                child: Icon(
                                  IconlyLight.upload,
                                  size: 70,
                                  color: Colors.pink,
                                ),
                              ),
                              SizedBox(height: 15),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.titleTextColor,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Click here! Upload 1–3 full-length pics\n(mirror selfies totally count).',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.titleTextColor,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Zuri will spill what cuts +\ncolors love you most. ✨ ',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0343249,
                  ),
                  Text(
                    'Clear lighting + full length pics = magic insights!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),
                  // Buttons
                  Column(
                    children: [
                      GlobalPinkButton(
                        text: 'here’s how to click pics that really click!',
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        onPressed: () {
                          context.goNamed('guidelines');
                        },
                      ),
                      SizedBox(height: 15),
                      GlobalTextButton(
                        onPressed: () {
                          context.goNamed('body_shape_option');
                        },
                        text: "Or choose from infographic",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0274599,
                      ),
                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already Have an Account? ',
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFF9EA2AE),
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle login
                              context.goNamed(
                                'login',
                                extra: "without signup, came from SignUp page",
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login Here',
                              style: GoogleFonts.libreFranklin(
                                color: Color(0xFF2563EB),
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Developer.log(
                            "User do skip on Scan and discover page.. now navigate to the Home Page before Login",
                          );
                          context.goNamed('home');
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.libreFranklin(
                            color: Colors.grey,
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),
                ],
              ),
            ),
          );
  }

  // void _showPicker() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: <Widget>[
  //             ListTile(
  //               leading: Icon(Icons.photo_library),
  //               title: Text('Gallery'),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 _pickImage(ImageSource.gallery);
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.camera_alt),
  //               title: Text('Camera'),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 _pickImage(ImageSource.camera);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

  // Widget _buildChatbotButton() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
  //     child: FloatingActionButton(
  //       onPressed: () {
  //         context.goNamed("chatbot");
  //       },
  //       backgroundColor: Color(0xFFF8BBB9),
  //       foregroundColor: Color(0xFF5D4037),
  //       elevation: 8,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //       child: Icon(Icons.chat_rounded, size: 28),
  //     ),
  //   );
  // }

  // Widget _buildWeatherLocationCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 22),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFFFFEBEA), Color(0xFFFFD6D5)],
  //       ),
  //       borderRadius: BorderRadius.circular(32),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Color(0xFFCBA6A5).withOpacity(0.2),
  //           blurRadius: 15,
  //           offset: Offset(0, 5),
  //         ),
  //       ],
  //       border: Border.all(color: Color(0xFFFFCECD), width: 1.5),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Current Season',
  //                 style: GoogleFonts.libreFranklin(
  //                   fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF8D6E63),
  //                 ),
  //               ),
  //               SizedBox(height: 5),
  //               isLoading
  //                   ? _buildLoadingIndicator(height: MediaQuery.of(context).size.height * 0.0274599)
  //                   : Text(
  //                     ResultCache.seasonData ?? 'Unknown',
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: MediaQuery.of(context).textScaler.scale(24),
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF5D4037),
  //                     ),
  //                   ),
  //               SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
  //               Row(
  //                 children: [
  //                   Icon(Icons.location_on, size: 16, color: Color(0xFF8D6E63)),
  //                   SizedBox(width: 4),
  //                   Expanded(
  //                     child:
  //                         isLoading
  //                             ? _buildLoadingIndicator(height: MediaQuery.of(context).size.height * 0.018306636)
  //                             : Text(
  //                               getFormattedLocation(),
  //                               style: GoogleFonts.libreFranklin(
  //                                 fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                                 fontWeight: FontWeight.w500,
  //                                 color: Color(0xFF8D6E63),
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(width: MediaQuery.of(context).size.width * 0.02487562),
  //         _buildRefreshButton(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildLoadingIndicator({required double height}) {
  //   return Container(
  //     height: height,
  //     width: MediaQuery.of(context).size.width * 0.248756,
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.5),
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Center(
  //       child: SizedBox(
  //         height: height - 8,
  //         width: height - 8,
  //         child: CircularProgressIndicator(
  //           strokewidth: MediaQuery.of(context).size.width * 0.004975124,
  //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8BBB9)),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildRefreshButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.4),
  //       shape: BoxShape.circle,
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(32),
  //         onTap: isRefreshing ? null : refreshLocationAndWeather,
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child:
  //               isRefreshing
  //                   ? SizedBox(
  //                     width: MediaQuery.of(context).size.width * 0.0049751244,
  //                     height: MediaQuery.of(context).size.height * 0.0274599,
  //                     child: CircularProgressIndicator(
  //                       strokewidth: MediaQuery.of(context).size.width * 0.004975124,
  //                       valueColor: AlwaysStoppedAnimation<Color>(
  //                         Color(0xFF5D4037),
  //                       ),
  //                     ),
  //                   )
  //                   : Icon(
  //                     Icons.refresh_rounded,
  //                     color: Color(0xFF5D4037),
  //                     size: 24,
  //                   ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //   Widget _buildImagePreviewContainer() {
  //     return Container(
  //       width: double.infinity,
  //       height: MediaQuery.of(context).size.height * 0.02059495,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Color(0xFFFFD6D5), Color(0xFFFFC2C0)],
  //         ),
  //         borderRadius: BorderRadius.circular(24),
  //         border: Border.all(color: Color(0xFFFFAEAC), width: 1.5),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Color(0xFFCBA6A5).withOpacity(0.3),
  //             blurRadius: 20,
  //             offset: Offset(0, 10),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(22),
  //               bottomLeft: Radius.circular(22),
  //             ),
  //             child: Image.asset(
  //               'assets/images/splash/s1.png',
  //               width: 150,
  //               height: 150,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Expanded(
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     Icons.photo_size_select_actual_outlined,
  //                     color: Color(0xFF5D4037),
  //                     size: 32,
  //                   ),
  //                   SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
  //                   Text(
  //                     "Upload full body image as the side image",
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                       fontWeight: FontWeight.w500,
  //                       color: Color(0xFF5D4037),
  //                       height: 1.5,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
  //                   Text(
  //                     "(recommended for better results)",
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                       fontWeight: FontWeight.w400,
  //                       color: Color(0xFF8D6E63),
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   Widget _buildUploadButton() {
  //     return ElevatedButton(
  //       onPressed: () {
  //         context.goNamed('autoUpload');
  //       },
  //       style: ElevatedButton.styleFrom(
  //         padding: EdgeInsets.symmetric(vertical: 15),
  //         minimumSize: Size(double.infinity, 60),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  //         backgroundColor: Color(0xFFF8BBB9),
  //         foregroundColor: Color(0xFF5D4037),
  //         elevation: 8,
  //         shadowColor: Color(0xFFCBA6A5).withOpacity(0.3),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.cloud_upload, size: 20),
  //           SizedBox(width: 12),
  //           Text(
  //             'Upload Image',
  //             style: GoogleFonts.libreFranklin(fontSize: MediaQuery.of(context).textScaler.scale(18), fontWeight: FontWeight.w600),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   Widget _buildDividerWithIcon() {
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: Container(
  //             height: 1.5,
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [
  //                   Color(0xFFCBA6A5).withOpacity(0.1),
  //                   Color(0xFFCBA6A5).withOpacity(0.6),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Container(
  //             padding: EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFF5C6C5).withOpacity(0.5),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(
  //               Icons.privacy_tip_outlined,
  //               color: Color(0xFF5D4037),
  //               size: 20,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Container(
  //             height: 1.5,
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [
  //                   Color(0xFFCBA6A5).withOpacity(0.6),
  //                   Color(0xFFCBA6A5).withOpacity(0.1),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   Widget _buildManualProcessButton() {
  //     return ElevatedButton(
  //       onPressed: () {
  //         context.goNamed("body_shape_option");
  //       },
  //       style: ElevatedButton.styleFrom(
  //         padding: EdgeInsets.symmetric(vertical: 15),
  //         minimumSize: Size(double.infinity, 60),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  //         backgroundColor: Color(0xFFFFD6D5),
  //         elevation: 0,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.check_circle_outline, color: Color(0xFF5D4037), size: 24),
  //           SizedBox(width: MediaQuery.of(context).size.width * 0.02487562),
  //           Text(
  //             'Manual Process',
  //             style: GoogleFonts.libreFranklin(
  //               fontSize: MediaQuery.of(context).textScaler.scale(18),
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF5D4037),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }}
