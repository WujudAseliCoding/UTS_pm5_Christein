import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Central light/dark themes for Kuis Cendekia.
abstract final class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Slightly enlarges typography on tablet and desktop while keeping the
  /// user's accessibility text scaling intact.
  static ThemeData withResponsiveTypography(ThemeData base, double width) {
    final factor = width < 600
        ? 1.0
        : width < 1040
        ? 1.035
        : 1.07;
    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: factor),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? AppPalette.dark : AppPalette.light;
    final scheme = (isDark ? _darkScheme : _lightScheme).copyWith(
      brightness: brightness,
    );
    final baseText = Typography.material2021(
      platform: TargetPlatform.android,
    ).black.apply(
      fontFamily: fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final textTheme = _textTheme(baseText);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: palette.optionBorder),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: palette.pageGradientStart,
      canvasColor: palette.pageGradientStart,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[palette],
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      dividerTheme: DividerThemeData(
        color: palette.cardBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.optionSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: palette.mutedText,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: palette.mutedText,
        ),
        prefixIconColor: palette.mutedText,
        suffixIconColor: palette.mutedText,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: palette.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.optionSurface,
        selectedColor: palette.softPrimary,
        disabledColor: palette.optionSurface,
        side: BorderSide(color: palette.optionBorder),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: scheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.nightSurfaceAlt : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: palette.softPrimary,
        linearMinHeight: 8,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightSurfaceAlt : AppColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.blue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.blueSoft,
    onPrimaryContainer: Color(0xFF0B1B33),
    secondary: AppColors.amber,
    onSecondary: Color(0xFF2B1D00),
    secondaryContainer: Color(0xFFFFF1D6),
    onSecondaryContainer: Color(0xFF6B4A00),
    tertiary: AppColors.mint,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.mintSoft,
    onTertiaryContainer: Color(0xFF053B2A),
    error: AppColors.coral,
    onError: Colors.white,
    errorContainer: AppColors.coralSoft,
    onErrorContainer: Color(0xFF5C0A0A),
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFBFDFF),
    surfaceContainer: Color(0xFFF3F7FD),
    surfaceContainerHigh: Color(0xFFECF2FA),
    surfaceContainerHighest: Color(0xFFE5EDF7),
    onSurfaceVariant: AppColors.inkSoft,
    outline: Color(0xFFC3CFE2),
    outlineVariant: AppColors.border,
    shadow: Color(0xFF0B1526),
    scrim: Color(0x66000000),
    inverseSurface: AppColors.ink,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.blueLight,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.blueLight,
    onPrimary: Color(0xFF07182F),
    primaryContainer: Color(0xFF1B2F52),
    onPrimaryContainer: Color(0xFFE3EDFF),
    secondary: Color(0xFFFFC24B),
    onSecondary: Color(0xFF2B1D00),
    secondaryContainer: Color(0xFF4A3610),
    onSecondaryContainer: Color(0xFFFFE1A3),
    tertiary: Color(0xFF4FDFAE),
    onTertiary: Color(0xFF03291C),
    tertiaryContainer: Color(0xFF12372C),
    onTertiaryContainer: Color(0xFFB9F5DF),
    error: Color(0xFFFF8A8A),
    onError: Color(0xFF3B0505),
    errorContainer: Color(0xFF3D1919),
    onErrorContainer: Color(0xFFFFD5D5),
    surface: AppColors.nightSurface,
    onSurface: AppColors.nightInk,
    surfaceContainerLowest: Color(0xFF070C14),
    surfaceContainerLow: Color(0xFF0E1622),
    surfaceContainer: AppColors.nightSurface,
    surfaceContainerHigh: AppColors.nightSurfaceAlt,
    surfaceContainerHighest: Color(0xFF1F2C40),
    onSurfaceVariant: AppColors.nightMuted,
    outline: Color(0xFF46566E),
    outlineVariant: AppColors.nightBorder,
    shadow: Colors.black,
    scrim: Color(0x99000000),
    inverseSurface: AppColors.nightInk,
    onInverseSurface: AppColors.ink,
    inversePrimary: AppColors.blue,
  );

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -1.4,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.6,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
      ),
    );
  }
}
