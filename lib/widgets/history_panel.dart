import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../data/models/question.dart';
import 'app_components.dart';
import 'empty_state.dart';
import 'score_ring.dart';

/// Recent scores and best result, persisted locally through
/// `HistoryController`.
class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    super.key,
    required this.items,
    required this.bestScore,
    required this.onClear,
    this.maxVisible = 6,
  });

  final List<QuizResult> items;
  final int bestScore;
  final VoidCallback onClear;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = items.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Riwayat skor',
          subtitle: 'Tersimpan lokal di perangkat ini',
          leadingIcon: Icons.history_rounded,
          actionLabel: items.isEmpty ? null : 'Hapus',
          onAction: onClear,
        ),
        SizedBox(height: context.rs(14)),
        if (items.isEmpty)
          AppCard(
            showShadow: false,
            child: EmptyState(
              imageAsset: 'assets/images/empty_history.svg',
              imageMaxWidth: context.rs(190),
              title: 'Belum ada skor',
              message:
                  'Selesaikan kuis pertamamu untuk melihat ringkasan hasil di sini.',
            ),
          )
        else ...<Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= context.rs(760)
                  ? 2
                  : 1;
              final gap = context.rs(10);
              final width = (constraints.maxWidth - gap * (columns - 1)) /
                  columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    child: StatTile(
                      icon: Icons.emoji_events_rounded,
                      label: 'Skor terbaik',
                      value: '$bestScore',
                      caption: 'Skor terbaik dari ${items.length} percobaan',
                      accent: context.palette.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: StatTile(
                      icon: Icons.query_stats_rounded,
                      label: 'Total percobaan',
                      value: '${items.length}×',
                      caption: 'Kuis yang sudah diselesaikan',
                      accent: context.palette.success,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: context.rs(14)),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= context.rs(980)
                  ? 3
                  : constraints.maxWidth >= context.rs(620)
                  ? 2
                  : 1;
              final gap = context.rs(10);
              final width = (constraints.maxWidth - gap * (columns - 1)) /
                  columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (var index = 0; index < visible.length; index++)
                    SizedBox(
                      width: width,
                      child: _HistoryCard(
                        key: Key('history-card-$index'),
                        result: visible[index],
                        isBest:
                            visible[index].completedAt ==
                            items
                                .reduce(
                                  (a, b) => a.score >= b.score ? a : b,
                                )
                                .completedAt,
                      ),
                    ),
                ],
              );
            },
          ),
          if (items.length > visible.length) ...<Widget>[
            SizedBox(height: context.rs(10)),
            Text(
              'Menampilkan ${visible.length} dari ${items.length} riwayat terbaru.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({super.key, required this.result, required this.isBest});

  final QuizResult result;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final scoreColor = result.score >= 80
        ? palette.success
        : result.score >= 60
        ? palette.warning
        : scheme.error;

    return AppCard(
      showShadow: false,
      padding: EdgeInsets.all(context.rs(14)),
      child: Row(
        children: <Widget>[
          Container(
            width: context.rs(42),
            height: context.rs(42),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.softPrimary,
              borderRadius: BorderRadius.circular(context.rs(13)),
            ),
            child: Text(
              AppFormatters.initials(result.playerName),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
              ),
            ),
          ),
          SizedBox(width: context.rs(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        result.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (isBest) ...<Widget>[
                      SizedBox(width: context.rs(5)),
                      Icon(
                        Icons.emoji_events_rounded,
                        size: context.rs(14),
                        color: palette.warning,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: context.rs(2)),
                Text(
                  '${result.settings.categoryLabel} • '
                  '${AppFormatters.shortDate(result.completedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rs(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${result.score}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scoreColor,
                ),
              ),
              Text(
                '${result.correctAnswers}/${result.totalQuestions} benar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.mutedText,
                  fontSize: context.rs(10.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
