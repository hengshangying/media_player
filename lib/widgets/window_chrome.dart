import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme.dart';

bool get supportsCustomWindowChrome {
  if (kIsWeb) return false;
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } catch (_) {
    return false;
  }
}

/// Dark custom caption bar aligned with the left sidebar width.
class AppWindowTitleBar extends StatefulWidget {
  const AppWindowTitleBar({
    super.key,
    this.title = '影音播放器',
    this.height = 40,
    this.sidebarWidth = 228,
  });

  final String title;
  final double height;
  final double sidebarWidth;

  @override
  State<AppWindowTitleBar> createState() => _AppWindowTitleBarState();
}

class _AppWindowTitleBarState extends State<AppWindowTitleBar>
    with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    if (supportsCustomWindowChrome) {
      windowManager.addListener(this);
      _refreshMaximized();
    }
  }

  @override
  void dispose() {
    if (supportsCustomWindowChrome) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _refreshMaximized() async {
    final value = await windowManager.isMaximized();
    if (mounted) setState(() => _maximized = value);
  }

  @override
  void onWindowMaximize() => _refreshMaximized();

  @override
  void onWindowUnmaximize() => _refreshMaximized();

  @override
  void onWindowRestore() => _refreshMaximized();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            // Brand strip sits above the sidebar for a continuous chrome.
            SizedBox(
              width: widget.sidebarWidth,
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.asset(
                          'assets/branding/app_mark.png',
                          width: 18,
                          height: 18,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, __, ___) => Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: AppColors.brandGradient,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.borderSubtle,
            ),
            const Expanded(
              child: DragToMoveArea(
                child: SizedBox.expand(),
              ),
            ),
            _CaptionButton(
              tooltip: '最小化',
              icon: Icons.remove_rounded,
              onPressed: () => windowManager.minimize(),
            ),
            _CaptionButton(
              tooltip: _maximized ? '还原' : '最大化',
              icon: _maximized
                  ? Icons.filter_none_rounded
                  : Icons.crop_square_rounded,
              iconSize: _maximized ? 12 : 14,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _CaptionButton(
              tooltip: '关闭',
              icon: Icons.close_rounded,
              danger: true,
              onPressed: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.danger = false,
    this.iconSize = 16,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool danger;
  final double iconSize;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = !_hover
        ? Colors.transparent
        : (widget.danger
            ? const Color(0xFFE81123)
            : AppColors.surfaceHover);
    final fg = widget.danger && _hover
        ? Colors.white
        : (_hover ? AppColors.textPrimary : AppColors.textMuted);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 600),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 46,
            height: double.infinity,
            color: bg,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: widget.iconSize, color: fg),
          ),
        ),
      ),
    );
  }
}
