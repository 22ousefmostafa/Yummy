import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double? width;

  const AppLogo({
    super.key,
    this.height = 48,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo.svg',
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}