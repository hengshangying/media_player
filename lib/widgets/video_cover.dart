import 'package:flutter/material.dart';

import '../api/media_api_client.dart';
import '../theme/app_theme.dart';

class VideoCover extends StatelessWidget {
  const VideoCover({
    super.key,
    required this.api,
    this.coverUrl,
    this.height = 120,
    this.width,
    this.borderRadius = 12,
    this.iconSize = 36,
    this.fill = false,
  });

  final MediaApiClient api;
  final String? coverUrl;
  final double height;
  final double? width;
  final double borderRadius;
  final double iconSize;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;
    final placeholder = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1424),
            Color(0xFF121626),
            Color(0xFF1C1030),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_filter_rounded,
          color: AppColors.textMuted.withValues(alpha: 0.65),
          size: iconSize,
        ),
      ),
    );

    Widget child;
    if (url == null || url.isEmpty) {
      child = placeholder;
    } else {
      child = Image.network(
        url,
        width: fill ? null : width,
        height: fill ? null : height,
        fit: BoxFit.cover,
        headers: api.authHeaders(),
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, image, progress) {
          if (progress == null) return image;
          return DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.surfaceHover),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentSoft.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        },
      );
    }

    if (fill) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
