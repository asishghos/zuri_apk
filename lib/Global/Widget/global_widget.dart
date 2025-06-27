import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:intl/intl.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 55,
      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.textPrimary,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 32),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon ?? false) ...[
              Icon(leftIconData ?? Icons.arrow_back_ios, size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.libreFranklin(
                fontSize: fontSize ?? 18,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
            if (rightIcon ?? false) ...[
              const SizedBox(width: 8),
              Icon(rightIconData ?? Icons.arrow_forward_ios, size: 24),
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
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.libreFranklin(
                fontSize: fontSize ?? 18,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
            if (rightIcon ?? false) ...[
              const SizedBox(width: 8),
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
          if (showlefticon) const SizedBox(width: 20),
          if (showlefticon)
            HugeIcon(
              icon: iconData ?? HugeIcons.strokeRoundedSearch01,
              color: Color(0xFFD34169),
            ),
          const SizedBox(width: 12),
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF131927),
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.libreFranklin(
            fontSize: 14,
            color: Color(0xFF394050),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.libreFranklin(
                fontSize: 14,
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
                // You can show error snackbar here if needed
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
              'Delete',
              style: GoogleFonts.libreFranklin(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}
