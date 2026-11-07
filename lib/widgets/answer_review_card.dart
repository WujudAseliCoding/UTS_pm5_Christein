import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../data/models/question.dart';
import 'app_components.dart';
import 'option_tile.dart';

/// Full question review with the selected answer, correct answer and an
/// explanation.
class AnswerReviewCard extends StatelessWidget {
  const AnswerReviewCard({
    super.key,
    required this.entry,
    required this.number,
  });

  final ReviewEntry entry;
  final int number;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final question = entry.question;
    final statusColor = entry.isCorrect
        ? palette.success
        : entry.isAnswered
        ? scheme.error
        : palette.warning;
    final statusBackground = entry.isCorrect
        ? palette.softSuccess
        : entry.isAnswered
        ? palette.softDanger
        : palette.softWarning;
    final statusIcon = entry.isCorrect
        ? Icons.check_circle_rounded
        : entry.isAnswered
        ? Icons.cancel_rounded
        : Icons.help_outline_rounded;
    final statusLabel = entry.isCorrect
        ? 'Benar'
        : entry.isAnswered
        ? 'Salah'
        : 'Tidak dijawab';

    return AppCard(
      key: Key('review-card-$number'),
      padding: EdgeInsets.all(context.rs(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: context.rs(34),
                height: context.rs(34),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.softPrimary,
                  borderRadius: BorderRadius.circular(context.rs(10)),
                ),
                child: Text(
                  '$number',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
              SizedBox(width: context.rs(9)),
              Flexible(
                child: AppBadge(
                  label: question.category.label,
                  icon: Icons.sell_outlined,
                ),
              ),
              const Spacer(),
              AppBadge(
                label: statusLabel,
                icon: statusIcon,
                foreground: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          SizedBox(height: context.rs(14)),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              height: 1.45,
            ),
          ),
          SizedBox(height: context.rs(14)),
          for (var index = 0; index < question.options.length; index++) ...<Widget>[
            OptionTile(
              index: index,
              text: question.options[index],
              state: index == question.correctIndex
                  ? OptionVisualState.correct
                  : index == entry.selectedIndex
                  ? OptionVisualState.wrong
                  : OptionVisualState.idle,
              disabled: true,
              dimmed: index != question.correctIndex &&
                  index != entry.selectedIndex,
            ),
            if (index != question.options.length - 1)
              SizedBox(height: context.rs(8)),
          ],
          SizedBox(height: context.rs(14)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.rs(14)),
            decoration: BoxDecoration(
              color: palette.softPrimary.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(context.rs(14)),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: context.rs(18),
                      color: scheme.primary,
                    ),
                    SizedBox(width: context.rs(7)),
                    Text(
                      'Pembahasan',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rs(6)),
                Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
