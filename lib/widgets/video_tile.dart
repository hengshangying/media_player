import 'package:flutter/material.dart';

import '../api/media_api_client.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';
import 'video_cover.dart';

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.item,
    required this.api,
    required this.onTap,
  });

  final VideoItem item;
  final MediaApiClient api;
  final VoidCallback onTap;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: _hover ? AppColors.surfaceHover : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.borderSubtle,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    VideoCover(
                      api: widget.api,
                      coverUrl: item.coverUrl,
                      width: 112,
                      height: 72,
                      borderRadius: 12,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              _typeLabel(item.type),
                              item.durationLabel,
                              if (item.resolution != null &&
                                  item.resolution!.isNotEmpty)
                                item.resolution!,
                            ].join(' · '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _hover ? AppColors.brandGradient : null,
                        color: _hover ? null : AppColors.surface,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 22,
                        color: _hover ? Colors.white : AppColors.textMuted,
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
