import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import '../api/api_exception.dart';
import '../api/media_api_client.dart';
import '../utils/format.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  final String videoId;
  final String title;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  Timer? _progressTimer;
  bool _loading = true;
  String? _error;
  bool _controlsVisible = true;
  bool _seeking = false;
  double _seekValue = 0;
  bool _progressDirty = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final api = context.read<MediaApiClient>();
    try {
      final play = await api.getPlayInfo(widget.videoId);
      double startAt = 0;
      try {
        final progress = await api.getProgress(widget.videoId);
        if (progress != null && progress.positionSec > 5) {
          startAt = progress.positionSec;
        }
      } catch (_) {}

      // API may return placeholder Authorization like "Bearer <same-token>".
      // Always let the client's real auth win for stream requests.
      final headers = <String, String>{
        ...play.headers,
        ...api.authHeaders(),
      };
      headers.removeWhere((k, v) {
        final key = k.toLowerCase();
        final val = v.toLowerCase();
        return key == 'authorization' &&
            (val.contains('<same-token>') || val.contains('placeholder'));
      });
      headers.addAll(api.authHeaders());

      await _player.open(
        Media(play.url, httpHeaders: headers),
        play: true,
      );

      // Wait briefly for duration; black screen with 00:00 usually means auth/stream fail.
      Duration ready = Duration.zero;
      try {
        ready = await _player.stream.duration
            .firstWhere((d) => d > Duration.zero)
            .timeout(const Duration(seconds: 12));
      } catch (_) {
        throw Exception('视频流未就绪（请检查 Base URL / Token / Tailscale）');
      }
      if (startAt > 0 && ready > Duration.zero) {
        await _player.seek(Duration(milliseconds: (startAt * 1000).round()));
      }

      _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _saveProgress(force: true);
      });

      if (!mounted) return;
      setState(() => _loading = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '播放失败：$e';
        _loading = false;
      });
    }
  }

  Future<void> _saveProgress({bool force = false}) async {
    if (!force && !_progressDirty) return;
    final pos = _player.state.position;
    final dur = _player.state.duration;
    if (dur <= Duration.zero) return;
    try {
      final api = context.read<MediaApiClient>();
      await api.putProgress(
        id: widget.videoId,
        positionSec: pos.inMilliseconds / 1000.0,
        durationSec: dur.inMilliseconds / 1000.0,
      );
      _progressDirty = false;
    } catch (_) {
      // Keep playing even if progress save fails.
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    // Periodic saves cover most progress; avoid using context after dispose.
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlay() {
    _player.playOrPause();
    _progressDirty = true;
  }

  Future<void> _onLeave() async {
    await _saveProgress(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await _onLeave();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _controlsVisible = !_controlsVisible),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('返回'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Center(
                  child: Video(
                    controller: _controller,
                    controls: NoVideoControls,
                  ),
                ),
                if (_loading)
                  const Center(child: CircularProgressIndicator()),
                if (_controlsVisible) _buildOverlay(),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildOverlay() {
    return StreamBuilder(
      stream: _player.stream.playing,
      builder: (context, _) {
        return StreamBuilder<Duration>(
          stream: _player.stream.position,
          builder: (context, posSnap) {
            return StreamBuilder<Duration>(
              stream: _player.stream.duration,
              builder: (context, durSnap) {
                final pos = _seeking
                    ? Duration(milliseconds: _seekValue.round())
                    : (posSnap.data ?? _player.state.position);
                final dur = durSnap.data ?? _player.state.duration;
                final maxMs = dur.inMilliseconds.toDouble().clamp(1, double.infinity);
                final value = _seeking
                    ? _seekValue.clamp(0, maxMs)
                    : pos.inMilliseconds.toDouble().clamp(0, maxMs);
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xCC000000),
                      ],
                      stops: [0, 0.25, 0.65, 1],
                    ),
                  ),
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    formatDuration(pos),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: value.toDouble(),
                                      max: maxMs.toDouble(),
                                      onChangeStart: (v) {
                                        setState(() {
                                          _seeking = true;
                                          _seekValue = v;
                                        });
                                      },
                                      onChanged: (v) {
                                        setState(() => _seekValue = v);
                                      },
                                      onChangeEnd: (v) async {
                                        await _player.seek(
                                          Duration(milliseconds: v.round()),
                                        );
                                        _progressDirty = true;
                                        setState(() => _seeking = false);
                                      },
                                    ),
                                  ),
                                  Text(
                                    formatDuration(dur),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 36,
                                    color: Colors.white,
                                    onPressed: () async {
                                      final next = _player.state.position -
                                          const Duration(seconds: 10);
                                      await _player.seek(
                                        next < Duration.zero ? Duration.zero : next,
                                      );
                                      _progressDirty = true;
                                    },
                                    icon: const Icon(Icons.replay_10),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    iconSize: 52,
                                    color: Colors.white,
                                    onPressed: _togglePlay,
                                    icon: Icon(
                                      _player.state.playing
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    iconSize: 36,
                                    color: Colors.white,
                                    onPressed: () async {
                                      final next = _player.state.position +
                                          const Duration(seconds: 10);
                                      await _player.seek(next);
                                      _progressDirty = true;
                                    },
                                    icon: const Icon(Icons.forward_10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
