import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

enum OptionVisualState { idle, selected, correct, wrong }

/// Answer option used both while answering and while reviewing.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
    this.disabled = false,
    this.dimmed = false,
  });

  final int index;
  final String text;
  final OptionVisualState state;
  final VoidCallback? onTap;
  final bool disabled;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final letter = String.fromCharCode(65 + index);
    final radius = BorderRadius.circular(context.rs(17));

    final (Color background, Color border, Color foreground) = switch (state) {
      OptionVisualState.selected => (
        palette.softPrimary,
        scheme.primary,
        scheme.primary,
      ),
      OptionVisualState.correct => (
        palette.softSuccess,
        palette.success,
        palette.success,
      ),
      OptionVisualState.wrong => (
        palette.softDanger,
        scheme.error,
        scheme.error,
      ),
      OptionVisualState.idle => (
        palette.optionSurface,
        palette.optionBorder,
        scheme.onSurface,
      ),
    };

    final effectiveBackground = dimmed
        ? background.withValues(alpha: 0.45)
        : background;
    final effectiveForeground = dimmed
        ? foreground.withValues(alpha: 0.55)
        : foreground;

    final trailing = switch (state) {
      OptionVisualState.selected => Icon(
        Icons.radio_button_checked_rounded,
        color: scheme.primary,
        size: context.rs(21),
      ),
      OptionVisualState.correct => Icon(
        Icons.check_circle_rounded,
        color: palette.success,
        size: context.rs(21),
      ),
      OptionVisualState.wrong => Icon(
        Icons.cancel_rounded,
        color: scheme.error,
        size: context.rs(21),
      ),
      OptionVisualState.idle => null,
    };

    final stateLabel = switch (state) {
      OptionVisualState.selected => 'dipilih',
      OptionVisualState.correct => 'jawaban benar',
      OptionVisualState.wrong => 'jawaban salah',
      OptionVisualState.idle => 'belum dipilih',
    };

    return Semantics(
      button: !disabled,
      selected: state == OptionVisualState.selected,
      label: 'Opsi $letter. $text. $stateLabel',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(14),
              vertical: context.rs(13),
            ),
            decoration: BoxDecoration(
              color: effectiveBackground,
              borderRadius: radius,
              border: Border.all(
                color: border,
                width: state == OptionVisualState.idle || dimmed ? 1 : 1.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: context.rs(32),
                  height: context.rs(32),
                  decoration: BoxDecoration(
                    color: state == OptionVisualState.idle
                        ? (dimmed
                              ? palette.optionBorder.withValues(alpha: 0.35)
                              : palette.softPrimary)
                        : effectiveForeground.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.rs(10)),
                    border: Border.all(
                      color: state == OptionVisualState.idle
                          ? palette.optionBorder
                          : border.withValues(alpha: 0.4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: effectiveForeground,
                    ),
                  ),
                ),
                SizedBox(width: context.rs(12)),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: dimmed
                          ? context.palette.mutedText
                          : scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  SizedBox(width: context.rs(8)),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
