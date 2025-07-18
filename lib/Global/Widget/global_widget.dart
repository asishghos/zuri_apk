import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/services/DataSource/product_api.dart';
import 'package:url_launcher/url_launcher.dart';

void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text("Success"),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text("Error"),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Retry"),
        ),
      ],
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

class GlobalPinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool? rightIcon;
  final bool? leftIcon;
  final IconData? leftIconData;
  final IconData? rightIconData;
  final bool? isLoading;

  const GlobalPinkButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.rightIcon,
    this.leftIcon,
    this.leftIconData,
    this.rightIconData,
    this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 55,
      child: ElevatedButton(
        onPressed: isLoading ?? false ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.textPrimary,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 32),
          ),
          elevation: 0,
        ),
        child: isLoading ?? false
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leftIcon ?? false) ...[
                    Icon(leftIconData ?? Icons.arrow_back_ios, size: 24),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.libreFranklin(
                      fontSize: fontSize ?? 18,
                      fontWeight: fontWeight ?? FontWeight.w600,
                    ),
                  ),
                  if (rightIcon ?? false) ...[
                    SizedBox(width: 8),
                    HugeIcon(
                      icon:
                          rightIconData ?? HugeIcons.strokeRoundedArrowRight01,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class GlobalTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool? rightIcon;
  final bool? leftIcon;
  final IconData? leftIconData;
  final IconData? rightIconData;
  final double? borderWidth;

  const GlobalTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.rightIcon,
    this.leftIcon,
    this.leftIconData,
    this.rightIconData,
    this.borderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        border: Border.all(
          color: AppColors.textPrimary,
          width: borderWidth ?? 1.5,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: foregroundColor ?? AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon ?? false) ...[
              Icon(leftIconData ?? Icons.arrow_back_ios, size: 24),
              SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.libreFranklin(
                fontSize: fontSize ?? 18,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
            if (rightIcon ?? false) ...[
              SizedBox(width: 8),
              Icon(rightIconData ?? Icons.arrow_forward_ios, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class GlobalRichTextDescription extends StatelessWidget {
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign? textAlign;
  final String? text;

  const GlobalRichTextDescription({
    Key? key,
    this.text,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign ?? TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.libreFranklin(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: textColor ?? AppColors.titleTextColor,
        ),
        children: [TextSpan(text: text)],
      ),
    );
  }
}

class GlobalSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final double height;
  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final IconData? iconData;
  // final Icon cameraIcon;
  final Color hintTextColor;
  final FontWeight hintFontWeight;
  final double hintFontSize;
  final EdgeInsets margin;
  final bool showlefticon;
  // final VoidCallback? onCameraTap;
  final ValueChanged<String>? onChanged;

  const GlobalSearchBar({
    super.key,
    this.controller,

    this.hintText = 'Search something...',
    this.height = 55,
    this.width = double.infinity,
    this.borderRadius = 32,
    this.showlefticon = true,
    this.backgroundColor = const Color(0xFFFFEBEB),
    this.borderColor = const Color(0xFFD34169),
    // this.cameraIcon = const Icon(
    //   Icons.camera_alt,
    //   color: Colors.black,
    //   size: 32,
    // ),
    this.hintTextColor = Colors.grey,
    this.hintFontWeight = FontWeight.w600,
    this.hintFontSize = 16,
    this.margin = const EdgeInsets.symmetric(horizontal: 0),
    // this.onCameraTap,
    this.onChanged,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (showlefticon)
            SizedBox(width: MediaQuery.of(context).size.width * 0.049751243),
          if (showlefticon)
            HugeIcon(
              icon: iconData ?? HugeIcons.strokeRoundedSearch01,
              color: Color(0xFFD34169),
            ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.libreFranklin(
                  color: hintTextColor,
                  fontWeight: hintFontWeight,
                  fontSize: hintFontSize,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: GestureDetector(onTap: onCameraTap, child: cameraIcon),
          // ),
        ],
      ),
    );
  }
}

String formatDate(DateTime date) {
  String day = DateFormat('d').format(date);
  String suffix = getDaySuffix(int.parse(day));
  String monthYear = DateFormat('MMM yyyy').format(date);
  return '$day$suffix $monthYear';
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

Future<void> showGlobalDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String buttonText,
  required Future<void> Function() onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).textScaler.scale(18),
            fontWeight: FontWeight.w600,
            color: Color(0xFF131927),
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(14),
            color: Color(0xFF394050),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                fontWeight: FontWeight.w500,
                color: Color(0xFF394050),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await onConfirm();
                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF5236),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ProductCard extends StatefulWidget {
  final String link;
  final String imageUrl;
  final String title;
  final String discountedPrice;
  final String store;
  final double dh;
  final bool initialFavorite;
  final Function(bool)? onFavoriteToggle; // Keep for parent notifications
  final String? productId; // Add productId parameter

  const ProductCard({
    super.key,
    required this.link,
    required this.imageUrl,
    required this.title,
    required this.discountedPrice,
    required this.store,
    required this.dh,
    this.initialFavorite = false,
    this.onFavoriteToggle,
    this.productId, // Add this parameter
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool isLoading = false;
  double _scale = 1.0;

  // Generate consistent product ID based on product data
  String _generateConsistentProductId() {
    if (widget.productId != null && widget.productId!.isNotEmpty) {
      return widget.productId!;
    }

    // Create a consistent ID based on product URL and title
    String baseString = "${widget.link}_${widget.title}";
    return baseString.hashCode.abs().toString();
  }

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialFavorite;
  }

  Future<void> _toggleWishlist() async {
    setState(() => isLoading = true);

    try {
      String productId = _generateConsistentProductId();

      Map<String, String> productData = {
        "productId": productId,
        "productUrl": widget.link,
        "productImage": widget.imageUrl,
        "productTitle": widget.title,
        "price": widget.discountedPrice,
        "platform": widget.store,
      };

      final result = await ProductApiServices.toggleWishlistItem(productData);

      if (result['success']) {
        setState(() {
          isFavorite = !isFavorite;
        });

        // Show appropriate message
        if (mounted) {
          if (isFavorite) {
            showSuccessSnackBar(context, "Added to wishlist");
          } else {
            showSuccessSnackBar(context, "Removed from wishlist");
          }
        }

        // Notify parent if callback exists
        if (widget.onFavoriteToggle != null) {
          widget.onFavoriteToggle!(isFavorite);
        }

        Developer.log(result['message']);
      } else {
        // Show error message
        if (mounted) {
          showErrorSnackBar(
            context,
            result['message'] ?? 'Failed to update wishlist',
          );
        }
        Developer.log('Error: ${result['message']}');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        showErrorSnackBar(context, 'Error updating wishlist: $e');
      }
      Developer.log('Error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onTapDown(_) => setState(() => _scale = 0.9);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await launchUrl(
            Uri.parse(widget.link),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          Developer.log('Error opening link: $e');
        }
      },
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  color: const Color(0xFFF5F5F5),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Text & Info
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE91E63),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price + Wishlist
                  Row(
                    children: [
                      Text(
                        widget.discountedPrice,
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      const Spacer(),

                      // Animated Favorite Icon
                      GestureDetector(
                        onTap: _toggleWishlist,
                        onTapDown: _onTapDown,
                        onTapUp: _onTapUp,
                        onTapCancel: () => setState(() => _scale = 1.0),
                        child: AnimatedScale(
                          scale: _scale,
                          duration: const Duration(milliseconds: 150),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background fill animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFavorite
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.transparent,
                                ),
                              ),

                              // Icon or Loader
                              isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder: (child, animation) =>
                                          ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                      child: isFavorite
                                          ? const HugeIcon(
                                              key: ValueKey('filled'),
                                              icon: HugeIcons
                                                  .strokeRoundedFavourite,
                                              color: Colors.red,
                                            )
                                          : const HugeIcon(
                                              key: ValueKey('outline'),
                                              icon: HugeIcons
                                                  .strokeRoundedFavourite,
                                              color: Colors.black,
                                            ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Store Text
                  Text(
                    widget.store,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
