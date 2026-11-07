import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';

/// Live elapsed-time indicator in the quiz header.
class QuizTimerChip extends StatelessWidget {
  const QuizTimerChip({super.key, required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: 'Waktu pengerjaan',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(11),
          vertical: context.rs(8),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(context.rs(13)),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.timer_outlined,
              size: context.rs(17),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: context.rs(6)),
            Text(
              AppFormatters.duration(elapsed),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact number grid for jumping between questions.
class QuestionNavigatorGrid extends StatelessWidget {
  const QuestionNavigatorGrid({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.isAnsweredAt,
    required this.onSelected,
    this.compact = false,
  });

  final int total;
  final int currentIndex;
  final bool Function(int index) isAnsweredAt;
  final ValueChanged<int> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = context.rs(compact ? 6 : 8);
        final columns = constraints.maxWidth < context.rs(250)
            ? 5
            : constraints.maxWidth < context.rs(380)
            ? 6
            : 8;
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final tileSize = tileWidth.clamp(context.rs(34), context.rs(50));

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (var index = 0; index < total; index++)
              _NumberTile(
                number: index + 1,
                size: tileSize,
                current: index == currentIndex,
                answered: isAnsweredAt(index),
                onTap: () => onSelected(index),
                compact: compact,
              ),
          ],
        );
      },
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.number,
    required this.size,
    required this.current,
    required this.answered,
    required this.onTap,
    required this.compact,
  });

  final int number;
  final double size;
  final bool current;
  final bool answered;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final radius = BorderRadius.circular(context.rs(compact ? 10 : 12));

    final background = answered ? scheme.primary : palette.optionSurface;
    final foreground = answered ? scheme.onPrimary : scheme.onSurface;

    return Semantics(
      button: true,
      selected: current,
      label:
          'Soal $number, ${answered ? 'sudah dijawab' : 'belum dijawab'}${current ? ', soal saat ini' : ''}',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: radius,
              border: Border.all(
                color: current
                    ? (answered ? palette.warning : scheme.primary)
                    : palette.optionBorder,
                width: current ? 2 : 1,
              ),
            ),
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: current ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Answered/total summary with a progress bar, reused on quiz layouts.
class QuizSummaryCard extends StatelessWidget {
  const QuizSummaryCard({
    super.key,
    required this.answered,
    required this.total,
    required this.currentNumber,
    required this.elapsed,
  });

  final int answered;
  final int total;
  final int currentNumber;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final progress = total == 0 ? 0.0 : answered / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Soal $currentNumber dari $total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$answered terjawab',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.mutedText,
              ),
            ),
          ],
        ),
        SizedBox(height: context.rs(10)),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: context.rs(8),
            backgroundColor: palette.softPrimary,
          ),
        ),
        SizedBox(height: context.rs(12)),
        Row(
          children: <Widget>[
            Icon(
              Icons.pending_actions_rounded,
              size: context.rs(16),
              color: palette.mutedText,
            ),
            SizedBox(width: context.rs(6)),
            Text(
              '${total - answered} belum dijawab',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.mutedText,
              ),
            ),
            const Spacer(),
            Text(
              AppFormatters.duration(elapsed),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.mutedText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
