import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soft cinematic wash behind library / search content.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.ambientGradient),
        ),
        // Subtle rose bloom top-left
        Positioned(
          top: -80,
          left: -40,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.14),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Violet bloom mid-right
        Positioned(
          top: 120,
          right: -60,
          child: IgnorePointer(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentAlt.withValues(alpha: 0.10),
                    AppColors.accentAlt.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
