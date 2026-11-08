import 'package:flutter/material.dart';

import 'app_colors.dart';

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
    softPrimary: AppColors.blueSoft,
    softSuccess: AppColors.mintSoft,
    softWarning: AppColors.amberSoft,
    softDanger: AppColors.coralSoft,
    optionSurface: Color(0xFFFBFDFF),
    optionBorder: Color(0xFFDEE7F4),
    pageGradientStart: Color(0xFFF6F9FF),
    pageGradientEnd: Color(0xFFF2F7FB),
    shadow: Color(0x14101A2E),
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
    softPrimary: Color(0xFF172B4A),
    softSuccess: Color(0xFF12372C),
    softWarning: Color(0xFF3B2D0D),
    softDanger: Color(0xFF3D1919),
    optionSurface: Color(0xFF141E2D),
    optionBorder: Color(0xFF25334A),
    pageGradientStart: Color(0xFF0A101B),
    pageGradientEnd: Color(0xFF0D1622),
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
      shadow: mix(shadow, other.shadow),
    );
  }
}

/// Convenient access to [AppPalette] from any widget.
extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
