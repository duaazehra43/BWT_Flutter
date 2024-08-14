// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final double padding;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.fontSize = 16.0,
    this.padding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.backgroundColor,
        padding:
            EdgeInsets.symmetric(vertical: padding.h, horizontal: padding.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: ColorConstants.foregroundColor,
          fontSize: fontSize.sp,
        ),
      ),
    );
  }
}
