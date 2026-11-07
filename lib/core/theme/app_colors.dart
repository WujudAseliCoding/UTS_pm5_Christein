import 'package:flutter/material.dart';

/// Named colors for the Kuis Cendekia brand.
///
/// Widgets should normally read colors from the active [ColorScheme] or the
/// [AppPalette] theme extension. These constants are the single source used to
/// build both themes.
abstract final class AppColors {
  static const Color ink = Color(0xFF241E3D);
  static const Color inkSoft = Color(0xFF6F6887);
  static const Color canvas = Color(0xFFF7F5FF);
  static const Color canvasAlt = Color(0xFFF1FBf8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E3F5);

  static const Color violet = Color(0xFF5A45D6);
  static const Color violetDeep = Color(0xFF3A2BA8);
  static const Color violetSoft = Color(0xFFEFEBFF);
  static const Color violetLight = Color(0xFFA79AFF);

  static const Color amber = Color(0xFFFFB020);
  static const Color amberSoft = Color(0xFFFFF3D9);
  static const Color mint = Color(0xFF12A97A);
  static const Color mintSoft = Color(0xFFE6F8F1);
  static const Color coral = Color(0xFFD64545);
  static const Color coralSoft = Color(0xFFFDECEC);

  static const Color night = Color(0xFF0D0B18);
  static const Color nightSurface = Color(0xFF191628);
  static const Color nightSurfaceAlt = Color(0xFF211D33);
  static const Color nightBorder = Color(0xFF2E2847);
  static const Color nightInk = Color(0xFFF4F1FF);
  static const Color nightMuted = Color(0xFFA9A1C0);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7F70F5), Color(0xFF4A37C9)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD166), Color(0xFFF59E19)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF37D6A0), Color(0xFF12A97A)],
  );
}
