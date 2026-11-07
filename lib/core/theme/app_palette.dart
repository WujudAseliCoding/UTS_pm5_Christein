import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Extra semantic colors that are not part of Material's [ColorScheme].
///
/// Keeping them in a [ThemeExtension] means light and dark mode stay in sync
/// and every widget can access the same tokens.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.mutedText,
    required this.cardBorder,
    required this.softPrimary,
    required this.softSuccess,
    required this.softWarning,
    required this.softDanger,
    required this.optionSurface,
    required this.optionBorder,
    required this.pageGradientStart,
    required this.pageGradientEnd,
    required this.blobPrimary,
    required this.blobSecondary,
    required this.shadow,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;
  final Color mutedText;
  final Color cardBorder;
  final Color softPrimary;
  final Color softSuccess;
  final Color softWarning;
  final Color softDanger;
  final Color optionSurface;
  final Color optionBorder;
  final Color pageGradientStart;
  final Color pageGradientEnd;
  final Color blobPrimary;
  final Color blobSecondary;
  final Color shadow;

  static const AppPalette light = AppPalette(
    success: AppColors.mint,
    onSuccess: Colors.white,
    warning: Color(0xFF9A6100),
    onWarning: Colors.white,
    danger: AppColors.coral,
    onDanger: Colors.white,
    mutedText: AppColors.inkSoft,
    cardBorder: AppColors.border,
    softPrimary: AppColors.violetSoft,
    softSuccess: AppColors.mintSoft,
    softWarning: AppColors.amberSoft,
    softDanger: AppColors.coralSoft,
    optionSurface: Color(0xFFFBFAFF),
    optionBorder: Color(0xFFE3DEF2),
    pageGradientStart: Color(0xFFF8F5FF),
    pageGradientEnd: Color(0xFFF3FBF8),
    blobPrimary: Color(0x335A45D6),
    blobSecondary: Color(0x26FFB020),
    shadow: Color(0x14241E3D),
  );

  static const AppPalette dark = AppPalette(
    success: Color(0xFF4FDFAE),
    onSuccess: Color(0xFF03291C),
    warning: Color(0xFFFFC24B),
    onWarning: Color(0xFF2B1D00),
    danger: Color(0xFFFF8A8A),
    onDanger: Color(0xFF3B0505),
    mutedText: AppColors.nightMuted,
    cardBorder: AppColors.nightBorder,
    softPrimary: Color(0xFF2A2451),
    softSuccess: Color(0xFF12372C),
    softWarning: Color(0xFF3B2D0D),
    softDanger: Color(0xFF3D1919),
    optionSurface: Color(0xFF201C33),
    optionBorder: Color(0xFF332D4D),
    pageGradientStart: Color(0xFF0F0C1D),
    pageGradientEnd: Color(0xFF131A24),
    blobPrimary: Color(0x337F70F5),
    blobSecondary: Color(0x1FFFBA3A),
    shadow: Color(0x66000000),
  );

  @override
  AppPalette copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? mutedText,
    Color? cardBorder,
    Color? softPrimary,
    Color? softSuccess,
    Color? softWarning,
    Color? softDanger,
    Color? optionSurface,
    Color? optionBorder,
    Color? pageGradientStart,
    Color? pageGradientEnd,
    Color? blobPrimary,
    Color? blobSecondary,
    Color? shadow,
  }) {
    return AppPalette(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      mutedText: mutedText ?? this.mutedText,
      cardBorder: cardBorder ?? this.cardBorder,
      softPrimary: softPrimary ?? this.softPrimary,
      softSuccess: softSuccess ?? this.softSuccess,
      softWarning: softWarning ?? this.softWarning,
      softDanger: softDanger ?? this.softDanger,
      optionSurface: optionSurface ?? this.optionSurface,
      optionBorder: optionBorder ?? this.optionBorder,
      pageGradientStart: pageGradientStart ?? this.pageGradientStart,
      pageGradientEnd: pageGradientEnd ?? this.pageGradientEnd,
      blobPrimary: blobPrimary ?? this.blobPrimary,
      blobSecondary: blobSecondary ?? this.blobSecondary,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      success: mix(success, other.success),
      onSuccess: mix(onSuccess, other.onSuccess),
      warning: mix(warning, other.warning),
      onWarning: mix(onWarning, other.onWarning),
      danger: mix(danger, other.danger),
      onDanger: mix(onDanger, other.onDanger),
      mutedText: mix(mutedText, other.mutedText),
      cardBorder: mix(cardBorder, other.cardBorder),
      softPrimary: mix(softPrimary, other.softPrimary),
      softSuccess: mix(softSuccess, other.softSuccess),
      softWarning: mix(softWarning, other.softWarning),
      softDanger: mix(softDanger, other.softDanger),
      optionSurface: mix(optionSurface, other.optionSurface),
      optionBorder: mix(optionBorder, other.optionBorder),
      pageGradientStart: mix(pageGradientStart, other.pageGradientStart),
      pageGradientEnd: mix(pageGradientEnd, other.pageGradientEnd),
      blobPrimary: mix(blobPrimary, other.blobPrimary),
      blobSecondary: mix(blobSecondary, other.blobSecondary),
      shadow: mix(shadow, other.shadow),
    );
  }
}

/// Convenient access to [AppPalette] from any widget.
extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
