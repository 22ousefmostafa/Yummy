import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle h1({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle h2({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle h3({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle h4({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle body1({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle body2({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle caption({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle button({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle small({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle smallBold({required Color color, String fontFamily = 'poppins'}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  static String fontFamily(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'ar' ? 'cairo' : 'poppins';
  }
}