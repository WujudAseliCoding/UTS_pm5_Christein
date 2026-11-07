import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Width breakpoints used across the app.
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 1040;
}

enum AppScreenType { compact, medium, expanded }

/// Screen-aware measurements.
///
/// Components never choose their own fixed pixel sizes. They derive padding,
/// radii, icon sizes and control heights from these helpers, while text comes
/// from the app's typography scale. This keeps the UI proportional from small
/// phones up to tablets and web viewports.
extension AppResponsive on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  AppScreenType get screenType {
    final width = screenSize.width;
    if (width < AppBreakpoints.compact) return AppScreenType.compact;
    if (width < AppBreakpoints.expanded) return AppScreenType.medium;
    return AppScreenType.expanded;
  }

  bool get isCompact => screenType == AppScreenType.compact;
  bool get isExpanded => screenType == AppScreenType.expanded;

  /// A clamped scale based on the shortest viewport edge. It avoids tiny
  /// controls on small phones and oversized ones on tablets.
  double get uiScale {
    final shortest = math.min(screenSize.width, screenSize.height);
    return (shortest / 390).clamp(0.86, 1.28);
  }

  double rs(num value) => value * uiScale;

  double rw(double fraction) => screenSize.width * fraction;

  EdgeInsets get pageInsets => EdgeInsets.symmetric(
    horizontal: isCompact ? rs(20) : rs(32),
    vertical: isCompact ? rs(16) : rs(28),
  );

  double get contentMaxWidth => 1180;

  EdgeInsets get cardPadding => EdgeInsets.all(isCompact ? rs(20) : rs(28));

  /// Selects a value using the current breakpoint, falling back to the compact
  /// value when a wider value is not supplied.
  T responsive<T>({required T compact, T? medium, T? expanded}) {
    return switch (screenType) {
      AppScreenType.compact => compact,
      AppScreenType.medium => medium ?? compact,
      AppScreenType.expanded => expanded ?? medium ?? compact,
    };
  }
}

/// Constrains page content to a comfortable reading width and applies
/// consistent responsive insets.
class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? context.contentMaxWidth),
        child: Padding(
          padding: padding ?? context.pageInsets,
          child: child,
        ),
      ),
    );
  }
}

/// A [LayoutBuilder]-based wrapper for cases where the available width differs
/// from the window width (for example inside a split layout).
class WidthBuilder extends StatelessWidget {
  const WidthBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, double width) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, constraints.maxWidth),
    );
  }
}
