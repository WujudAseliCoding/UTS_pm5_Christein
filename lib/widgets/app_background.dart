import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

/// Soft gradient canvas shared by every page.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            palette.pageGradientStart,
            palette.pageGradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Standard scaffold used by all screens: gradient background, safe area,
/// fixed header, scrollable content and an optional fixed bottom bar.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.header,
    this.bottomBar,
    this.scrollable = true,
    this.maxWidth,
    this.contentPadding,
  });

  final Widget child;
  final Widget? header;
  final Widget? bottomBar;
  final bool scrollable;
  final double? maxWidth;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final insets = context.pageInsets;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final effectivePadding =
        contentPadding ??
        EdgeInsets.only(
          left: insets.left,
          right: insets.right,
          top: context.rs(6),
          bottom: safeBottom + context.rs(28),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: SafeArea(
          bottom: bottomBar == null,
          child: Column(
            children: <Widget>[
              if (header != null)
                PageContainer(
                  maxWidth: maxWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: insets.left,
                    vertical: context.rs(10),
                  ),
                  child: header!,
                ),
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: effectivePadding,
                        child: PageContainer(
                          maxWidth: maxWidth,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      )
                    : PageContainer(
                        maxWidth: maxWidth,
                        padding: effectivePadding,
                        child: child,
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(top: false, child: bottomBar!),
    );
  }
}
