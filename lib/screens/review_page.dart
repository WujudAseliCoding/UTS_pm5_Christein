import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../data/models/question.dart';
import '../state/quiz_controller.dart';
import '../widgets/answer_review_card.dart';
import '../widgets/app_background.dart';
import '../widgets/app_components.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/score_ring.dart';

enum ReviewFilter { all, wrong, unanswered, correct }

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  ReviewFilter _filter = ReviewFilter.all;

  bool _matches(ReviewFilter filter, ReviewEntry entry) {
    return switch (filter) {
      ReviewFilter.all => true,
      ReviewFilter.wrong => entry.isWrong,
      ReviewFilter.unanswered => !entry.isAnswered,
      ReviewFilter.correct => entry.isCorrect,
    };
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final entries = quiz.reviewEntries;
    final result = quiz.result;

    if (entries.isEmpty) {
      return PageScaffold(
        header: AppTopBar(
          title: 'Pembahasan',
          showBack: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        child: AppCard(
          child: EmptyState(
            imageAsset: 'assets/images/empty_history.svg',
            title: 'Pembahasan belum tersedia',
            message:
                'Selesaikan kuis terlebih dahulu untuk melihat rincian jawaban.',
            action: AppButton(
              label: 'Kembali',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
    }

    final counts = <ReviewFilter, int>{
      ReviewFilter.all: entries.length,
      ReviewFilter.correct: entries.where((entry) => entry.isCorrect).length,
      ReviewFilter.wrong: entries.where((entry) => entry.isWrong).length,
      ReviewFilter.unanswered: entries
          .where((entry) => !entry.isAnswered)
          .length,
    };

    final visible = <(int, ReviewEntry)>[
      for (var index = 0; index < entries.length; index++)
        if (_matches(_filter, entries[index])) (index, entries[index]),
    ];

    return PageScaffold(
      maxWidth: 940,
      header: AppTopBar(
        title: 'Pembahasan',
        subtitle: result == null
            ? 'Rincian jawaban'
            : '${result.correctAnswers} benar • '
                  '${result.wrongAnswers} salah • '
                  '${result.unansweredQuestions} kosong',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReviewSummary(
            total: entries.length,
            correct: counts[ReviewFilter.correct]!,
            score: result?.score ?? 0,
          ),
          SizedBox(height: context.rs(16)),
          Wrap(
            spacing: context.rs(8),
            runSpacing: context.rs(8),
            children: <Widget>[
              for (final filter in ReviewFilter.values)
                ChoicePill(
                  label:
                      '${switch (filter) {
                        ReviewFilter.all => 'Semua',
                        ReviewFilter.correct => 'Benar',
                        ReviewFilter.wrong => 'Salah',
                        ReviewFilter.unanswered => 'Kosong',
                      }} (${counts[filter]})',
                  selected: _filter == filter,
                  dense: true,
                  onTap: () => setState(() => _filter = filter),
                ),
            ],
          ),
          SizedBox(height: context.rs(14)),
          if (visible.isEmpty)
            AppCard(
              child: EmptyState(
                imageAsset: 'assets/images/empty_history.svg',
                imageMaxWidth: context.rs(150),
                title: 'Tidak ada soal di filter ini',
                message: 'Coba pilih filter lain untuk melihat jawabanmu.',
                action: AppButton(
                  label: 'Tampilkan semua',
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      setState(() => _filter = ReviewFilter.all),
                ),
              ),
            )
          else
            for (final item in visible) ...<Widget>[
              AnswerReviewCard(
                entry: item.$2,
                number: item.$1 + 1,
              ),
              SizedBox(height: context.rs(12)),
            ],
          SizedBox(height: context.rs(6)),
          AppButton(
            label: 'Kembali ke hasil',
            icon: Icons.arrow_back_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
    required this.total,
    required this.correct,
    required this.score,
  });

  final int total;
  final int correct;
  final int score;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      showShadow: false,
      padding: EdgeInsets.all(context.rs(16)),
      child: Row(
        children: <Widget>[
          ScoreRing(score: score, diameter: context.rs(104)),
          SizedBox(width: context.rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rincian jawabanmu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: context.rs(4)),
                Text(
                  'Kamu menjawab benar $correct dari $total soal. '
                  'Baca pembahasan untuk memahami setiap jawaban.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.rs(8)),
                AppBadge(
                  label: '${((correct / total) * 100).round()}% akurasi',
                  icon: Icons.percent_rounded,
                  foreground: scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
