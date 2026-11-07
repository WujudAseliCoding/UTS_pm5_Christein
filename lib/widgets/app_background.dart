import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

/// Soft gradient canvas with decorative blobs, shared by every page.
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
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final shortest = constraints.biggest.shortestSide;
              final primary = shortest * 0.9;
              final secondary = shortest * 0.65;
              return IgnorePointer(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: -primary * 0.32,
                      right: -primary * 0.2,
                      child: _Blob(
                        size: primary,
                        color: palette.blobPrimary,
                      ),
                    ),
                    Positioned(
                      bottom: -secondary * 0.4,
                      left: -secondary * 0.3,
                      child: _Blob(
                        size: secondary,
                        color: palette.blobSecondary,
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.46,
                      left: constraints.maxWidth * 0.58,
                      child: _Blob(
                        size: secondary * 0.7,
                        color: palette.blobPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[color, color.withValues(alpha: 0)],
        ),
      ),
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
