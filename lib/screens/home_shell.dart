import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme.dart';
import '../widgets/window_chrome.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    LibraryScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  static const _destinations = <_NavDest>[
    _NavDest(
      label: '片库',
      icon: Icons.video_library_outlined,
      selectedIcon: Icons.video_library_rounded,
    ),
    _NavDest(
      label: '搜索',
      icon: Icons.search_rounded,
      selectedIcon: Icons.search_rounded,
    ),
    _NavDest(
      label: '我的',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  /// Windows always uses a left sidebar (desktop software feel).
  /// Android / narrow mobile keep the bottom NavigationBar.
  bool get _useSideRail {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_useSideRail) {
      return _DesktopShell(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
        destinations: _destinations,
        pages: _pages,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _DesktopShell(
            index: _index,
            onSelect: (i) => setState(() => _index = i),
            destinations: _destinations,
            pages: _pages,
          );
        }
        return Scaffold(
          body: IndexedStack(index: _index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NavDest {
  const _NavDest({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.index,
    required this.onSelect,
    required this.destinations,
    required this.pages,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<_NavDest> destinations;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      body: Row(
        children: [
          _SideNav(
            index: index,
            onSelect: onSelect,
            destinations: destinations,
            flushWithTitleBar: supportsCustomWindowChrome,
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.bg,
              child: IndexedStack(index: index, children: pages),
            ),
          ),
        ],
      ),
    );

    if (!supportsCustomWindowChrome) {
      return body;
    }

    return DragToResizeArea(
      child: Column(
        children: [
          const AppWindowTitleBar(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.index,
    required this.onSelect,
    required this.destinations,
    required this.flushWithTitleBar,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<_NavDest> destinations;
  final bool flushWithTitleBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: !flushWithTitleBar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, flushWithTitleBar ? 12 : 20, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppColors.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/branding/app_mark.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flushWithTitleBar ? '导航' : '影音播放器',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '私人片库',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    _SideNavItem(
                      dest: destinations[i],
                      selected: index == i,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bg.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  (!kIsWeb && Platform.isWindows)
                      ? 'Windows 桌面版'
                      : '桌面版',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  const _SideNavItem({
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final _NavDest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final bg = selected
        ? AppColors.accent.withValues(alpha: 0.16)
        : (_hover ? AppColors.surfaceHover : Colors.transparent);
    final fg = selected ? AppColors.accentSoft : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.32))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  children: [
                    if (selected)
                      Container(
                        width: 3,
                        height: 18,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(width: 13),
                    Icon(
                      selected ? widget.dest.selectedIcon : widget.dest.icon,
                      size: 20,
                      color: fg,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.dest.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: fg,
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
}
