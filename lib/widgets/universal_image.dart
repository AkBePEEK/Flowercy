import 'package:flutter/material.dart';
import 'dart:convert';

class UniversalImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;

  const UniversalImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) => placeholder ?? _defaultPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    } else if (imagePath!.startsWith('assets/') || imagePath!.contains('.png') || imagePath!.contains('.jpg')) {
      return Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) => placeholder ?? _defaultPlaceholder(),
      );
    } else {
      // Try base64
      try {
        String base64Str = imagePath!;
        if (base64Str.contains(',')) {
          base64Str = base64Str.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Str),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder ?? (context, error, stackTrace) => placeholder ?? _defaultPlaceholder(),
        );
      } catch (e) {
        return placeholder ?? _defaultPlaceholder();
      }
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
