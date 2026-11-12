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

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _loading = true;
  String? _error;
  List<VideoItem> _items = [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = context.read<MediaApiClient>();
    try {
      final result = await api.listVideos(page: 1, pageSize: 50);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _total = result.total;
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
        _error = '无法连接后端：$e';
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
        appBar: AppBar(
          title: const Text('片库'),
          actions: [
            IconButton(
              tooltip: '刷新',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.accentSoft,
          backgroundColor: AppColors.surfaceRaised,
          onRefresh: _load,
          child: _buildBody(api),
        ),
      ),
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      child: Row(
        children: [
          const Text(
            '精选海报墙',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.22),
                  AppColors.accentAlt.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              '共 $count 部',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.accentSoft,
              ),
            ),
          ),
          const Spacer(),
          if (_loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    String? detail,
    VoidCallback? action,
    String actionLabel = '重试',
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.22),
                          AppColors.accentAlt.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                    child: Icon(icon, size: 32, color: AppColors.accentSoft),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
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
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: 20),
                    FilledButton(onPressed: action, child: Text(actionLabel)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(MediaApiClient api) {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return _emptyState(
        icon: Icons.cloud_off_rounded,
        title: '无法加载片库',
        detail: _error,
        action: _load,
      );
    }
    if (_items.isEmpty) {
      return _emptyState(
        icon: Icons.video_library_outlined,
        title: '暂无视频',
        detail: '请先在后端上传影片，然后点刷新。',
        action: _load,
        actionLabel: '刷新',
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
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(_total)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                    // Taller posters for wall feel
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _items[index];
                      return VideoCard(
                        item: item,
                        api: api,
                        onTap: () => _openPlayer(item),
                      );
                    },
                    childCount: _items.length,
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: _items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _header(_total);
            final item = _items[index - 1];
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
