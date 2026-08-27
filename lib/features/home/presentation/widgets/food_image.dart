import 'package:flutter/material.dart';

class FoodImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackIcon;
  final double iconSize;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FoodImage({
    super.key,
    this.imageUrl,
    required this.fallbackIcon,
    this.iconSize = 40,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      Widget image = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _icon(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );

      if (borderRadius != null) {
        image = ClipRRect(borderRadius: borderRadius!, child: image);
      }
      return image;
    }
    return _icon();
  }

  Widget _icon() => Text(
        fallbackIcon,
        style: TextStyle(fontSize: iconSize),
      );
}
