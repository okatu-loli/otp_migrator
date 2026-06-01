import 'package:flutter/material.dart';

/// OTP Migrator design system — "Terminal Ledger".
///
/// A calm, credible security/utility look: flat slate surfaces, hairline
/// borders, near-zero elevation, a single muted teal-green accent, and a
/// deliberate sans-for-chrome / mono-for-data type contrast.
///
/// Deliberately rejects generic "AI aesthetics": no purple→blue gradients,
/// no glassmorphism, no neon glow, no centered hero card.
///
/// All design tokens are exposed as the stable API consumed by UI widgets:
/// [AppTheme], [AppSpacing], [AppRadii], [AppBorders], [AppBreakpoints] and the
/// [AppSemanticColors] theme extension.
class AppTheme {
  AppTheme._();

  /// Generic monospace family. Flutter maps this to the platform mono font
  /// (SF Mono / Roboto Mono / Consolas / DejaVu Sans Mono). Widgets that render
  /// secrets, otpauth URLs or metadata should use this for the data-under-glass
  /// treatment. No bundled font, no new dependency.
  static const String monoFontFamily = 'monospace';

  static ThemeData get light => _build(_lightScheme, _lightSemantics);
  static ThemeData get dark => _build(_darkScheme, _darkSemantics);

  // ---------------------------------------------------------------------------
  // Color schemes (explicit roles — not just a seed).
  // ---------------------------------------------------------------------------

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F7B6C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDEAE3),
    onPrimaryContainer: Color(0xFF053A32),
    secondary: Color(0xFF4A5D59),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE2E9E7),
    onSecondaryContainer: Color(0xFF27302E),
    tertiary: Color(0xFF1B5FA8),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD3E3F6),
    onTertiaryContainer: Color(0xFF062744),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF6D7D4),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF15201F),
    surfaceDim: Color(0xFFE7EBEA),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F8F8),
    surfaceContainer: Color(0xFFF2F4F4),
    surfaceContainerHigh: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF5A6664),
    outline: Color(0xFFD6DBDB),
    outlineVariant: Color(0xFFE4E8E8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF263130),
    onInverseSurface: Color(0xFFEFF2F1),
    inversePrimary: Color(0xFF3DBFA8),
    surfaceTint: Color(0xFF0F7B6C),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3DBFA8),
    onPrimary: Color(0xFF06241F),
    primaryContainer: Color(0xFF11433A),
    onPrimaryContainer: Color(0xFFBFEFE4),
    secondary: Color(0xFFB6C6C2),
    onSecondary: Color(0xFF1F2B29),
    secondaryContainer: Color(0xFF2A3735),
    onSecondaryContainer: Color(0xFFD6E2DF),
    tertiary: Color(0xFF6FB3F2),
    onTertiary: Color(0xFF062744),
    tertiaryContainer: Color(0xFF0E3354),
    onTertiaryContainer: Color(0xFFCFE3F8),
    error: Color(0xFFF2796E),
    onError: Color(0xFF49100B),
    errorContainer: Color(0xFF492220),
    onErrorContainer: Color(0xFFF6D6D2),
    surface: Color(0xFF161B1D),
    onSurface: Color(0xFFE6ECEB),
    surfaceDim: Color(0xFF0E1213),
    surfaceBright: Color(0xFF272E30),
    surfaceContainerLowest: Color(0xFF0B0F10),
    surfaceContainerLow: Color(0xFF13191A),
    surfaceContainer: Color(0xFF161B1D),
    surfaceContainerHigh: Color(0xFF1B2123),
    surfaceContainerHighest: Color(0xFF20282A),
    onSurfaceVariant: Color(0xFF9AA8A5),
    outline: Color(0xFF2C3538),
    outlineVariant: Color(0xFF222A2D),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6ECEB),
    onInverseSurface: Color(0xFF1A2122),
    inversePrimary: Color(0xFF0F7B6C),
    surfaceTint: Color(0xFF3DBFA8),
  );

  // ---------------------------------------------------------------------------
  // Semantic status colors.
  // ---------------------------------------------------------------------------

  static const AppSemanticColors _lightSemantics = AppSemanticColors(
    success: Color(0xFF0F7B5A),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFCDEEDF),
    onSuccessContainer: Color(0xFF053524),
    warning: Color(0xFF9A6500),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFF6E6C4),
    onWarningContainer: Color(0xFF3A2600),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    dangerContainer: Color(0xFFF6D7D4),
    onDangerContainer: Color(0xFF410E0B),
    info: Color(0xFF1B5FA8),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFD3E3F6),
    onInfoContainer: Color(0xFF062744),
  );

  static const AppSemanticColors _darkSemantics = AppSemanticColors(
    success: Color(0xFF34C98C),
    onSuccess: Color(0xFF053524),
    successContainer: Color(0xFF0E3B2A),
    onSuccessContainer: Color(0xFFBFF0DC),
    warning: Color(0xFFE0A93B),
    onWarning: Color(0xFF2A1C00),
    warningContainer: Color(0xFF3E2E08),
    onWarningContainer: Color(0xFFF4E3BD),
    danger: Color(0xFFF2796E),
    onDanger: Color(0xFF49100B),
    dangerContainer: Color(0xFF492220),
    onDangerContainer: Color(0xFFF6D6D2),
    info: Color(0xFF6FB3F2),
    onInfo: Color(0xFF062744),
    infoContainer: Color(0xFF0E3354),
    onInfoContainer: Color(0xFFCFE3F8),
  );

  // ---------------------------------------------------------------------------
  // Theme assembly.
  // ---------------------------------------------------------------------------

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantics) {
    final textTheme = _textTheme(scheme);
    final isLight = scheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[semantics],

      // Flat by default — hairlines do the separation work.
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: scheme.outline, width: AppBorders.hairline),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: AppBorders.hairline,
        space: AppBorders.hairline,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outline, width: AppBorders.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest == scheme.surface
            ? scheme.surfaceContainer
            : scheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: scheme.outline, width: AppBorders.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: scheme.outline, width: AppBorders.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: scheme.error, width: AppBorders.hairline),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 3,
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
          side: BorderSide(color: scheme.outline, width: AppBorders.hairline),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      popupMenuTheme: PopupMenuThemeData(
        elevation: 3,
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          side: BorderSide(color: scheme.outline, width: AppBorders.hairline),
        ),
        textStyle: textTheme.bodyMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        side: BorderSide.none,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: scheme.outlineVariant,
        overlayColor: WidgetStateProperty.all(
          scheme.primary.withValues(alpha: 0.06),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),

      splashFactory: isLight ? InkRipple.splashFactory : InkSparkle.splashFactory,
    );
  }

  // ---------------------------------------------------------------------------
  // Type scale — sans for chrome (platform default), tuned Material 3 roles.
  // Mono is applied per-widget via [monoFontFamily].
  // ---------------------------------------------------------------------------

  static TextTheme _textTheme(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    final onVariant = scheme.onSurfaceVariant;

    return TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        height: 1.4,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: onVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: onVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: onVariant,
      ),
    );
  }
}

/// Numeric spacing scale (8pt base with a 4pt half-step).
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii. Restrained and engineered — not toy-like.
class AppRadii {
  AppRadii._();

  static const double chip = 6;
  static const double control = 8;
  static const double card = 12;
  static const double dialog = 16;
  static const double pill = 999;
}

/// Border widths. The hairline does almost all separation work.
class AppBorders {
  AppBorders._();

  static const double hairline = 1.0;
}

/// Responsive breakpoints.
class AppBreakpoints {
  AppBreakpoints._();

  /// At/above this width the home screen uses the two-column working surface;
  /// below it collapses to the Import / Results tab layout.
  static const double expanded = 900;
}

/// Status colors (success / warning / danger / info) for both brightnesses.
///
/// Read via `Theme.of(context).extension<AppSemanticColors>()!`.
///
/// Note: `danger` is the destructive/error status color, kept separate from
/// the [ColorScheme.error] role so callers have a stable, semantic name.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color onDangerContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer:
          Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}
