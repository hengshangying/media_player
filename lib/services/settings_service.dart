import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Holds baseUrl + apiToken. Token is never logged.
/// Priority: SharedPreferences → dart-define → config/dev.json (desktop debug only).
class SettingsService extends ChangeNotifier {
  SettingsService();

  static const _kBaseUrl = 'base_url';
  static const _kApiToken = 'api_token';
  static const _kDeviceId = 'device_id';
  static const defaultBaseUrl = 'http://100.119.228.18:8787';

  late SharedPreferences _prefs;
  String _baseUrl = defaultBaseUrl;
  String _apiToken = '';
  String _deviceId = '';

  String get baseUrl => _baseUrl;
  String get apiToken => _apiToken;
  String get deviceId => _deviceId;
  bool get hasToken => _apiToken.isNotEmpty;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _baseUrl = _prefs.getString(_kBaseUrl) ?? '';
    _apiToken = _prefs.getString(_kApiToken) ?? '';
    _deviceId = _prefs.getString(_kDeviceId) ?? '';

    if (_deviceId.isEmpty) {
      _deviceId = 'flutter-${const Uuid().v4()}';
      await _prefs.setString(_kDeviceId, _deviceId);
    }

    // dart-define overrides empty prefs
    const defineBase = String.fromEnvironment('API_BASE_URL');
    const defineToken = String.fromEnvironment('API_TOKEN');
    if (_baseUrl.isEmpty && defineBase.isNotEmpty) {
      _baseUrl = defineBase;
    }
    if (_apiToken.isEmpty && defineToken.isNotEmpty) {
      _apiToken = defineToken;
    }

    // Desktop local file config/dev.json (gitignored) for first-run convenience
    if ((_baseUrl.isEmpty || _apiToken.isEmpty) && !kIsWeb) {
      await _tryLoadDevJson();
    }

    if (_baseUrl.isEmpty) {
      _baseUrl = defaultBaseUrl;
    }

    // Persist anything we bootstrapped so Settings UI shows them
    if (_prefs.getString(_kBaseUrl) == null) {
      await _prefs.setString(_kBaseUrl, _baseUrl);
    }
    if (_apiToken.isNotEmpty && (_prefs.getString(_kApiToken) ?? '').isEmpty) {
      await _prefs.setString(_kApiToken, _apiToken);
    }

    notifyListeners();
  }

  Future<void> _tryLoadDevJson() async {
    try {
      // Look relative to cwd (flutter run from project root) and next to executable.
      final candidates = <File>[
        File('config/dev.json'),
        File('../config/dev.json'),
      ];
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final exeDir = File(Platform.resolvedExecutable).parent;
        candidates.add(File('${exeDir.path}/config/dev.json'));
        candidates.add(File('${exeDir.parent.path}/config/dev.json'));
      }
      for (final f in candidates) {
        if (await f.exists()) {
          final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
          if (_baseUrl.isEmpty && map['baseUrl'] is String) {
            _baseUrl = map['baseUrl'] as String;
          }
          if (_apiToken.isEmpty && map['apiToken'] is String) {
            _apiToken = map['apiToken'] as String;
          }
          break;
        }
      }
    } catch (_) {
      // Ignore missing/invalid local config.
    }
  }

  Future<void> update({String? baseUrl, String? apiToken}) async {
    if (baseUrl != null) {
      _baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      await _prefs.setString(_kBaseUrl, _baseUrl);
    }
    if (apiToken != null) {
      _apiToken = apiToken.trim();
      await _prefs.setString(_kApiToken, _apiToken);
    }
    notifyListeners();
  }
}
