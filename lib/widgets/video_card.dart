import 'package:flutter/material.dart';

import '../api/media_api_client.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';
import 'video_cover.dart';

/// Poster-wall card: full-bleed cover, title fade, hover scale + glow.
class VideoCard extends StatefulWidget {
  const VideoCard({
    super.key,
    required this.item,
    required this.api,
    required this.onTap,
  });

  final VideoItem item;
  final MediaApiClient api;
  final VoidCallback onTap;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scale = _hover ? 1.045 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.55 : 0.28),
                blurRadius: _hover ? 28 : 14,
                offset: Offset(0, _hover ? 14 : 8),
              ),
              if (_hover)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  blurRadius: 26,
                  spreadRadius: 0.5,
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoCover(
                      api: widget.api,
                      coverUrl: item.coverUrl,
                      borderRadius: 0,
                      iconSize: 44,
                      fill: true,
                    ),
                    // Strong bottom title fade
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.posterTitleFade,
                      ),
                    ),
                    // Soft top vignette
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Meta chips
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _Chip(label: _typeLabel(item.type)),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _Chip(label: item.durationLabel, dense: true),
                    ),
                    // Title block
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          if (item.resolution != null &&
                              item.resolution!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.resolution!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Play overlay
                    AnimatedOpacity(
                      opacity: _hover ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.28),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.brandGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'movie':
        return '电影';
      case 'episode':
        return '剧集';
      case 'music':
        return '音乐';
      default:
        return type;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: dense ? 10.5 : 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}
