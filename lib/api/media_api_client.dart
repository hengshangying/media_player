import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/video_item.dart';
import '../services/settings_service.dart';
import 'api_exception.dart';

class MediaApiClient {
  MediaApiClient(this._settings);

  final SettingsService _settings;
  final http.Client _http = http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = _settings.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    final token = _settings.apiToken;
    if (token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  /// Auth only for media_kit / image loads.
  /// Do not send Accept: application/json on binary streams — the API returns 502.
  Map<String, String> authHeaders() {
    final h = <String, String>{};
    final token = _settings.apiToken;
    if (token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<Map<String, dynamic>> _unwrap(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        '响应不是 JSON（HTTP ${res.statusCode}）',
        statusCode: res.statusCode,
      );
    }
    if (res.statusCode == 401) {
      throw ApiException(
        '鉴权失败，请在设置中重新配置 Token',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );
    }
    final ok = body['ok'] == true;
    if (!ok) {
      final err = body['error'];
      String message = '请求失败';
      String? code;
      if (err is Map) {
        message = (err['message'] as String?) ?? message;
        code = err['code'] as String?;
      }
      throw ApiException(message, code: code, statusCode: res.statusCode);
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) return Future.value(data);
    if (data == null) return Future.value(<String, dynamic>{});
    return Future.value({'value': data});
  }

  Future<VideoListResult> listVideos({
    String? q,
    String type = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = <String, String>{
      'type': type,
      'page': '$page',
      'page_size': '$pageSize',
    };
    if (q != null && q.trim().isNotEmpty) {
      query['q'] = q.trim();
    }
    final res = await _http.get(_uri('/api/v1/videos', query), headers: _headers);
    final data = await _unwrap(res);
    return VideoListResult.fromJson(data);
  }

  Future<VideoListResult> search(String q, {int page = 1, int pageSize = 20}) async {
    final query = <String, String>{
      'q': q,
      'page': '$page',
      'page_size': '$pageSize',
    };
    final res = await _http.get(_uri('/api/v1/search', query), headers: _headers);
    final data = await _unwrap(res);
    return VideoListResult.fromJson(data);
  }

  Future<VideoItem> getVideo(String id) async {
    final res = await _http.get(_uri('/api/v1/videos/$id'), headers: _headers);
    final data = await _unwrap(res);
    return VideoItem.fromJson(data);
  }

  Future<PlayInfo> getPlayInfo(String id, {String quality = 'source'}) async {
    final res = await _http.get(
      _uri('/api/v1/videos/$id/play', {'quality': quality}),
      headers: _headers,
    );
    final data = await _unwrap(res);
    return PlayInfo.fromJson(data);
  }

  Future<void> putProgress({
    required String id,
    required double positionSec,
    required double durationSec,
  }) async {
    final res = await _http.put(
      _uri('/api/v1/videos/$id/progress'),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'position_sec': positionSec,
        'duration_sec': durationSec,
        'device_id': _settings.deviceId,
      }),
    );
    await _unwrap(res);
  }

  Future<WatchProgress?> getProgress(String id) async {
    final res = await _http.get(
      _uri('/api/v1/videos/$id/progress', {
        'device_id': _settings.deviceId,
      }),
      headers: _headers,
    );
    try {
      final data = await _unwrap(res);
      if (data.isEmpty) return null;
      return WatchProgress.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  void dispose() => _http.close();
}
