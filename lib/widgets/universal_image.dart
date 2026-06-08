import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api/api_config.dart';

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
        headers: const {'bypass-tunnel-reminder': 'true'},
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorBuilder?.call(context, error, stackTrace) ?? placeholder ?? _defaultPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    } else if (imagePath!.startsWith('/') || imagePath!.startsWith('file://')) {
      // Local file path
      final String path = imagePath!.replaceFirst('file://', '');
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorBuilder?.call(context, error, stackTrace) ?? placeholder ?? _defaultPlaceholder(),
      );
    } else if (imagePath!.startsWith('catalog/') || imagePath!.startsWith('outputs/')) {
      final String fullUrl = '${ApiConfig.baseUrl}/static/$imagePath';
      return Image.network(
        fullUrl,
        headers: const {'bypass-tunnel-reminder': 'true'},
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (imagePath!.startsWith('catalog/')) {
            // Try fallback to local assets
            final String fileName = imagePath!.split('/').last;
            // First try products, then catalog
            return Image.asset(
              'assets/flowers/products/$fileName',
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/flowers/catalog/$fileName',
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => errorBuilder?.call(context, error, stackTrace) ?? placeholder ?? _defaultPlaceholder(),
                );
              },
            );
          }
          return errorBuilder?.call(context, error, stackTrace) ?? placeholder ?? _defaultPlaceholder();
        },
      );
    } else if (imagePath!.startsWith('assets/') || imagePath!.contains('.png') || imagePath!.contains('.jpg')) {
      // Ensure it starts with assets/ if it's just a filename
      String finalPath = imagePath!;
      if (!finalPath.startsWith('assets/') && !finalPath.startsWith('http')) {
        // This is a heuristic, might need adjustment
        if (finalPath.contains('products/')) finalPath = 'assets/flowers/$finalPath';
        else if (finalPath.contains('catalog/')) finalPath = 'assets/flowers/$finalPath';
        else if (finalPath.contains('homeScreen/')) finalPath = 'assets/flowers/$finalPath';
        else finalPath = 'assets/$finalPath';
      }
      return Image.asset(
        finalPath,
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
        // Basic check if it's likely base64 (not a file path or random string)
        if (base64Str.length < 10) return placeholder ?? _defaultPlaceholder();
        
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
