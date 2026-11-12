import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_exception.dart';
import '../api/media_api_client.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_backdrop.dart';
import '../widgets/video_card.dart';
import '../widgets/video_tile.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  List<VideoItem> _items = [];
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    final api = context.read<MediaApiClient>();
    try {
      final result = await api.search(q);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '搜索失败：$e';
        _loading = false;
      });
    }
  }

  void _openPlayer(VideoItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(videoId: item.id, title: item.title),
      ),
    );
  }

  bool get _preferGrid {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<MediaApiClient>();
    return AmbientBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('搜索')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: '搜索标题…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: '搜索',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _loading ? null : _search,
                  ),
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Expanded(child: _buildResults(api)),
          ],
        ),
      ),
    );
  }

  Widget _hintCard({
    required IconData icon,
    required String title,
    String? detail,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accentAlt.withValues(alpha: 0.16),
                    ],
                  ),
                ),
                child: Icon(icon, size: 28, color: AppColors.accentSoft),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(MediaApiClient api) {
    if (!_searched) {
      return _hintCard(
        icon: Icons.search_rounded,
        title: '输入关键词搜索片库',
        detail: '支持按标题模糊匹配',
      );
    }
    if (_error != null) {
      return _hintCard(
        icon: Icons.error_outline_rounded,
        title: '搜索出错',
        detail: _error,
      );
    }
    if (_items.isEmpty && !_loading) {
      return _hintCard(
        icon: Icons.movie_filter_outlined,
        title: '没有匹配结果',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = _preferGrid || constraints.maxWidth >= 720;
        if (useGrid) {
          final width = constraints.maxWidth;
          final cross = width >= 1500
              ? 6
              : width >= 1200
                  ? 5
                  : width >= 960
                      ? 4
                      : width >= 640
                          ? 3
                          : 2;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 16,
              mainAxisSpacing: 18,
              childAspectRatio: 0.66,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return VideoCard(
                item: item,
                api: api,
                onTap: () => _openPlayer(item),
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return VideoTile(
              item: item,
              api: api,
              onTap: () => _openPlayer(item),
            );
          },
        );
      },
    );
  }
}
