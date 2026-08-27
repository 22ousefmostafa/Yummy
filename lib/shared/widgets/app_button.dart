import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? margin;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultStyle = theme.elevatedButtonTheme.style;
    final resolvedForegroundColor =
        foregroundColor ?? defaultStyle?.foregroundColor?.resolve({}) ?? Colors.white;

    final customStyle = ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, height),
      maximumSize: Size(double.infinity, height),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: AppTextStyles.button(color: resolvedForegroundColor),
    );

    return Container(
      margin: margin,
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: customStyle,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    resolvedForegroundColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}