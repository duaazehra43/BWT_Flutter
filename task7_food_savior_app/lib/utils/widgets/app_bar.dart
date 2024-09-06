import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';

PreferredSize buildAppBar() {
  return PreferredSize(
    preferredSize: Size.fromHeight(80.h),
    child: AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 65, top: 35),
        child: Text(
          'Food Savior',
          style: GoogleFonts.inter(color: foregroundColor),
        ),
      ),
      backgroundColor: primaryColor,
      iconTheme: const IconThemeData(color: iconTheme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20.r),
        ),
      ),
    ),
  );
}
