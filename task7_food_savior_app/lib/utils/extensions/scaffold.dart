import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';

extension SnackBarExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: foregroundColor),
        ),
        backgroundColor: primaryColor,
      ),
    );
  }
}
