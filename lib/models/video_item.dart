class VideoItem {
  VideoItem({
    required this.id,
    required this.title,
    required this.type,
    this.durationSec,
    this.sizeBytes,
    this.resolution,
    this.coverUrl,
    this.createdAt,
    this.updatedAt,
    this.path,
    this.mime,
    this.subtitleTracks = const [],
    this.qualities = const [],
  });

  final String id;
  final String title;
  final String type;
  final int? durationSec;
  final int? sizeBytes;
  final String? resolution;
  final String? coverUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? path;
  final String? mime;
  final List<SubtitleTrackInfo> subtitleTracks;
  final List<QualityInfo> qualities;

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'movie',
      durationSec: (json['duration_sec'] as num?)?.toInt(),
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      resolution: json['resolution'] as String?,
      coverUrl: json['cover_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      path: json['path'] as String?,
      mime: json['mime'] as String?,
      subtitleTracks: (json['subtitle_tracks'] as List<dynamic>? ?? [])
          .map((e) => SubtitleTrackInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      qualities: (json['qualities'] as List<dynamic>? ?? [])
          .map((e) => QualityInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get durationLabel {
    final sec = durationSec;
    if (sec == null || sec <= 0) return '--:--';
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class SubtitleTrackInfo {
  SubtitleTrackInfo({
    required this.id,
    this.lang,
    this.label,
    this.url,
  });

  final String id;
  final String? lang;
  final String? label;
  final String? url;

  factory SubtitleTrackInfo.fromJson(Map<String, dynamic> json) {
    return SubtitleTrackInfo(
      id: json['id'] as String,
      lang: json['lang'] as String?,
      label: json['label'] as String?,
      url: json['url'] as String?,
    );
  }
}

class QualityInfo {
  QualityInfo({
    required this.id,
    this.label,
    this.width,
    this.height,
  });

  final String id;
  final String? label;
  final int? width;
  final int? height;

  factory QualityInfo.fromJson(Map<String, dynamic> json) {
    return QualityInfo(
      id: json['id'] as String,
      label: json['label'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }
}

class VideoListResult {
  VideoListResult({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int total;
  final List<VideoItem> items;

  factory VideoListResult.fromJson(Map<String, dynamic> json) {
    return VideoListResult(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayInfo {
  PlayInfo({
    required this.playType,
    required this.url,
    this.expiresIn,
    this.headers = const {},
  });

  final String playType;
  final String url;
  final int? expiresIn;
  final Map<String, String> headers;

  factory PlayInfo.fromJson(Map<String, dynamic> json) {
    final rawHeaders = json['headers'];
    final headers = <String, String>{};
    if (rawHeaders is Map) {
      rawHeaders.forEach((k, v) {
        final key = '$k';
        final val = '$v';
        // Docs placeholder, not a real credential.
        if (key.toLowerCase() == 'authorization' &&
            (val.contains('<same-token>') ||
                val.toLowerCase().contains('placeholder'))) {
          return;
        }
        headers[key] = val;
      });
    }
    return PlayInfo(
      playType: (json['play_type'] as String?) ?? 'direct',
      url: json['url'] as String,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      headers: headers,
    );
  }
}

class WatchProgress {
  WatchProgress({
    required this.positionSec,
    this.durationSec,
  });

  final double positionSec;
  final double? durationSec;

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      positionSec: (json['position_sec'] as num?)?.toDouble() ?? 0,
      durationSec: (json['duration_sec'] as num?)?.toDouble(),
    );
  }
}
