import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? primaryColor : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: foregroundColor,
          fontSize: fontSize.sp,
        ),
      ),
    );
  }
}
