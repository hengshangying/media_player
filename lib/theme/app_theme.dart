import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cinematic streaming palette — deep charcoal, rose accent, violet glow.
/// Inspired by premium poster-wall UIs (original theme, not a copy).
class AppColors {
  static const bg = Color(0xFF07080D);
  static const bgDeep = Color(0xFF05060A);
  static const surface = Color(0xFF0E1018);
  static const surfaceRaised = Color(0xFF151826);
  static const surfaceHover = Color(0xFF1C2030);
  static const border = Color(0xFF2C3348);
  static const borderSubtle = Color(0xFF1A1F2E);

  static const accent = Color(0xFFE8457A);
  static const accentSoft = Color(0xFFFF6B9D);
  static const accentAlt = Color(0xFF8B5CF6);
  static const accentGlow = Color(0xFF5B8CFF);

  static const textPrimary = Color(0xFFF5F6FA);
  static const textSecondary = Color(0xFFA8B0C4);
  static const textMuted = Color(0xFF6E7690);
  static const danger = Color(0xFFFF6B7A);

  static const posterScrimTop = Color(0x00000000);
  static const posterScrimMid = Color(0x99000000);
  static const posterScrimBottom = Color(0xE6000000);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentAlt],
  );

  static const LinearGradient ambientGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF120A14),
      Color(0xFF07080D),
      Color(0xFF0A0E18),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient posterTitleFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      posterScrimTop,
      posterScrimMid,
      posterScrimBottom,
    ],
    stops: [0.35, 0.7, 1.0],
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
    primary: AppColors.accent,
    secondary: AppColors.accentAlt,
    surface: AppColors.surface,
    error: AppColors.danger,
  ).copyWith(
    surfaceContainerHighest: AppColors.surfaceRaised,
    outline: AppColors.border,
    outlineVariant: AppColors.borderSubtle,
  );

  final baseText = Typography.material2021(platform: TargetPlatform.windows)
      .white
      .apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.bg,
    dividerColor: AppColors.borderSubtle,
    splashFactory: InkSparkle.splashFactory,
    textTheme: baseText.copyWith(
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: baseText.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: AppColors.textMuted,
        height: 1.35,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceRaised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      height: 68,
      indicatorColor: AppColors.accent.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.accentSoft : AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? AppColors.accentSoft : AppColors.textMuted,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: AppColors.accent.withValues(alpha: 0.22),
      selectedIconTheme: const IconThemeData(
        color: AppColors.accentSoft,
        size: 22,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.textMuted,
        size: 22,
      ),
      selectedLabelTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.accentSoft,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHover,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentSoft,
      linearTrackColor: AppColors.borderSubtle,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
  );
}
