import 'dart:math' as math;
import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double mobileDesignWidth = 390.0;

  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);

    if (width >= 1024) return width * 0.18;
    if (width >= 700) return width * 0.12;
    if (width >= 600) return width * 0.10;
    if (width < 360) return 20;
    return 24;
  }

  static double authMaxWidth(BuildContext context) {
    final width = screenWidth(context);

    if (width >= 1024) return 420;
    if (width >= 700) return 440;
    if (width >= 600) return 460;
    return width;
  }

  static double scale(BuildContext context, double size) {
    final factor = screenWidth(context) / mobileDesignWidth;
    return size * factor.clamp(0.90, 1.18);
  }

  static double gapXS(BuildContext context) => scale(context, 4);
  static double gapSM(BuildContext context) => scale(context, 8);
  static double gapMD(BuildContext context) => scale(context, 12);
  static double gapLG(BuildContext context) => scale(context, 16);
  static double gapXL(BuildContext context) => scale(context, 20);
  static double gapXXL(BuildContext context) => scale(context, 24);
  static double gapSection(BuildContext context) => scale(context, 32);

  static double iconSize(BuildContext context, {double base = 22}) {
    return scale(context, base);
  }

  static double logoSize(BuildContext context) {
    return scale(context, 34);
  }

  static double buttonHeight(BuildContext context) {
    return isSmallPhone(context) ? 52 : 56;
  }

  static double textScaleAware(
    BuildContext context,
    double fontSize,
  ) {
    final textScale = MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
    return fontSize * math.min(textScale, 1.15);
  }
}