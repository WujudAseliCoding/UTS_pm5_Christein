import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// Single button API so every call to action has the same responsive height,
/// radius, focus state and loading feedback.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = (compact ? context.rs(44) : context.rs(54)).clamp(
      42.0,
      64.0,
    );
    final radius = BorderRadius.circular(context.rs(compact ? 13 : 16));
    final enabled = onPressed != null && !isLoading;
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final iconSize = context.rs(compact ? 18 : 20);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.3,
              color: variant == AppButtonVariant.primary
                  ? scheme.onPrimary
                  : variant == AppButtonVariant.danger
                  ? scheme.onError
                  : scheme.primary,
            ),
          )
        else if (icon != null)
          Icon(icon, size: iconSize),
        if (isLoading || icon != null) SizedBox(width: context.rs(10)),
        Flexible(
          child: Text(
            isLoading ? 'Memproses…' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final padding = EdgeInsets.symmetric(
      horizontal: context.rs(compact ? 16 : 22),
      vertical: context.rs(8),
    );
    final minimumSize = Size(fullWidth ? double.infinity : 0, height);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          side: BorderSide(color: palette.cardBorder),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: content,
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Rounded surface used for form panels, question cards, stats and summary
/// sections. Padding, radius and shadow all follow the viewport scale.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.color,
    this.borderColor,
    this.radius,
    this.onTap,
    this.showShadow = true,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final VoidCallback? onTap;
  final bool showShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final effectiveRadius = radius ?? context.rs(26);
    final effectivePadding = padding ?? context.cardPadding;

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: gradient == null ? color ?? scheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(color: borderColor ?? palette.cardBorder),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: context.rs(34),
                  offset: Offset(0, context.rs(14)),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveRadius),
        clipBehavior: clipBehavior,
        child: onTap == null
            ? Padding(padding: effectivePadding, child: child)
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(effectiveRadius),
                child: Padding(padding: effectivePadding, child: child),
              ),
      ),
    );

    return decorated;
  }
}

/// Small labelled status chip.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final color = foreground ?? scheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(10),
        vertical: context.rs(6),
      ),
      decoration: BoxDecoration(
        color: background ?? palette.softPrimary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: context.rs(14), color: color),
            SizedBox(width: context.rs(6)),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              Icon(
                leadingIcon,
                size: context.rs(20),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: context.rs(8)),
            ],
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...<Widget>[
          SizedBox(height: context.rs(4)),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
        ],
      ],
    );

    if (actionLabel == null) return titleBlock;

    return LayoutBuilder(
      builder: (context, constraints) {
        final action = TextButton(
          onPressed: onAction,
          child: Text(actionLabel!),
        );
        if (constraints.maxWidth < context.rs(360)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleBlock,
              SizedBox(height: context.rs(4)),
              action,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: titleBlock),
            SizedBox(width: context.rs(12)),
            action,
          ],
        );
      },
    );
  }
}
