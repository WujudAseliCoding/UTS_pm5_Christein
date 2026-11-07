import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

/// Friendly empty state with an original SVG illustration and optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.message,
    this.action,
    this.imageMaxWidth,
  });

  final String imageAsset;
  final String title;
  final String message;
  final Widget? action;
  final double? imageMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.rs(430)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: imageMaxWidth ?? context.rs(220),
              ),
              child: SvgPicture.asset(
                imageAsset,
                fit: BoxFit.contain,
                semanticsLabel: title,
              ),
            ),
            SizedBox(height: context.rs(12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: context.rs(6)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            if (action != null) ...<Widget>[
              SizedBox(height: context.rs(18)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable selectable pill for categories, quiz length and filters.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.dense = false,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool dense;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final radius = BorderRadius.circular(context.rs(dense ? 12 : 15));

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(dense ? 12 : 15),
              vertical: context.rs(dense ? 9 : 11),
            ),
            decoration: BoxDecoration(
              color: selected ? palette.softPrimary : palette.optionSurface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? scheme.primary : palette.optionBorder,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: context.rs(dense ? 16 : 18),
                    color: selected ? scheme.primary : palette.mutedText,
                  ),
                  SizedBox(width: context.rs(7)),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? scheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: dense
                        ? Theme.of(context).textTheme.labelMedium?.fontSize
                        : null,
                  ),
                ),
                if (selected) ...<Widget>[
                  SizedBox(width: context.rs(6)),
                  Icon(
                    Icons.check_rounded,
                    size: context.rs(16),
                    color: scheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
