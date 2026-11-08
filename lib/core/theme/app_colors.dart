import 'package:flutter/material.dart';

/// Named colors for the Kuis Cendekia brand.
///
/// Widgets should normally read colors from the active [ColorScheme] or the
/// [AppPalette] theme extension. These constants are the single source used to
/// build both themes.
abstract final class AppColors {
  static const Color ink = Color(0xFF101A2E);
  static const Color inkSoft = Color(0xFF5D6B82);
  static const Color canvas = Color(0xFFF5F8FE);
  static const Color canvasAlt = Color(0xFFF2F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDFE7F4);

  static const Color blue = Color(0xFF2F5FD7);
  static const Color blueDeep = Color(0xFF1E3F9E);
  static const Color blueSoft = Color(0xFFE9F0FF);
  static const Color blueLight = Color(0xFF8FB3FF);

  static const Color amber = Color(0xFFFFB020);
  static const Color amberSoft = Color(0xFFFFF3D9);
  static const Color mint = Color(0xFF12A97A);
  static const Color mintSoft = Color(0xFFE6F8F1);
  static const Color coral = Color(0xFFD64545);
  static const Color coralSoft = Color(0xFFFDECEC);

  static const Color night = Color(0xFF0A101C);
  static const Color nightSurface = Color(0xFF111A29);
  static const Color nightSurfaceAlt = Color(0xFF172234);
  static const Color nightBorder = Color(0xFF26344A);
  static const Color nightInk = Color(0xFFEEF3FC);
  static const Color nightMuted = Color(0xFF9BA9BE);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B8DEF), Color(0xFF2B54C4)],
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
