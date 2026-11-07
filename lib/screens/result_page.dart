import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/routing/app_router.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../data/models/question.dart';
import '../state/history_controller.dart';
import '../state/quiz_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/app_components.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/score_ring.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  void _goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  void _retry(BuildContext context, QuizResult result) {
    context.read<QuizController>().startQuiz(
      playerName: result.playerName,
      settings: result.settings,
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.quiz);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final history = context.watch<HistoryController>();
    final result = quiz.result;

    if (result == null) {
      return PageScaffold(
        header: AppTopBar(
          title: 'Hasil kuis',
          showBack: true,
          onBack: () => _goHome(context),
        ),
        child: AppCard(
          child: EmptyState(
            imageAsset: 'assets/images/trophy.svg',
            title: 'Belum ada hasil',
            message:
                'Selesaikan kuis terlebih dahulu untuk melihat skor dan pembahasan.',
            action: AppButton(
              label: 'Kembali ke beranda',
              icon: Icons.home_rounded,
              onPressed: () => _goHome(context),
            ),
          ),
        ),
      );
    }

    final isRecord = history.isNewRecord(result);
    final hasPrevious = history.hasPreviousAttempts(result);
    final greeting = _greeting(result.score);
    final insight = _insight(result.score);

    return PageScaffold(
      maxWidth: 1120,
      header: AppTopBar(
        title: 'Hasil kuis',
        subtitle: AppFormatters.dateTime(result.completedAt),
        showBack: false,
        actions: <Widget>[
          AppIconButton(
            icon: Icons.home_outlined,
            tooltip: 'Kembali ke beranda',
            onPressed: () => _goHome(context),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= context.rs(860);
          final hero = _ResultHero(
            result: result,
            greeting: greeting,
            isRecord: isRecord,
            hasPrevious: hasPrevious,
          );
          final details = _ResultDetails(
            result: result,
            insight: insight,
            onReview: () => Navigator.of(context).pushNamed(AppRoutes.review),
            onRetry: () => _retry(context, result),
            onHome: () => _goHome(context),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                hero,
                SizedBox(height: context.rs(14)),
                details,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 11, child: hero),
              SizedBox(width: context.rs(18)),
              Expanded(flex: 10, child: details),
            ],
          );
        },
      ),
    );
  }

  static String _greeting(int score) {
    if (score >= 90) return 'Luar biasa!';
    if (score >= 75) return 'Kerja bagus!';
    if (score >= 60) return 'Terus berkembang!';
    return 'Jangan menyerah!';
  }

  static String _insight(int score) {
    if (score >= 80) {
      return 'Penguasaanmu sangat baik. Coba kategori lain atau tingkatkan '
          'jumlah soal untuk tantangan baru.';
    }
    if (score >= 60) {
      return 'Kamu sudah memahami sebagian besar materi. Baca kembali '
          'pembahasan soal yang salah untuk memperkuat pemahaman.';
    }
    return 'Setiap percobaan adalah latihan. Pelajari pembahasan, lalu coba '
        'lagi dengan kategori yang sama.';
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.result,
    required this.greeting,
    required this.isRecord,
    required this.hasPrevious,
  });

  final QuizResult result;
  final String greeting;
  final bool isRecord;
  final bool hasPrevious;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          palette.softPrimary,
          scheme.surface,
          scheme.surface,
        ],
      ),
      borderColor: scheme.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: context.rs(8),
            runSpacing: context.rs(8),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              AppBadge(
                label: result.settings.categoryLabel,
                icon: Icons.sell_outlined,
              ),
              if (isRecord)
                AppBadge(
                  label: 'Rekor baru!',
                  icon: Icons.emoji_events_rounded,
                  foreground: palette.warning,
                  background: palette.softWarning,
                )
              else if (!hasPrevious)
                AppBadge(
                  label: 'Percobaan pertama',
                  icon: Icons.auto_awesome_rounded,
                  foreground: palette.success,
                  background: palette.softSuccess,
                ),
            ],
          ),
          SizedBox(height: context.rs(16)),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= context.rs(480);
              final illustration = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: horizontal ? context.rs(230) : context.rs(220),
                ),
                child: SvgPicture.asset(
                  'assets/images/trophy.svg',
                  fit: BoxFit.contain,
                  semanticsLabel: 'Ilustrasi piala hasil kuis',
                ),
              );
              final scoreBlock = Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ScoreRing(
                    score: result.score,
                    diameter: horizontal
                        ? context.rs(200)
                        : context.rs(185),
                  ),
                  SizedBox(height: context.rs(10)),
                  Text(
                    '${result.correctAnswers} benar dari '
                    '${result.totalQuestions} soal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.mutedText,
                    ),
                  ),
                ],
              );

              if (horizontal) {
                return Row(
                  children: <Widget>[
                    Expanded(child: illustration),
                    SizedBox(width: context.rs(12)),
                    Expanded(child: scoreBlock),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  illustration,
                  SizedBox(height: context.rs(4)),
                  scoreBlock,
                ],
              );
            },
          ),
          SizedBox(height: context.rs(18)),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: context.rs(4)),
          Text(
            result.playerName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.primary,
            ),
          ),
          SizedBox(height: context.rs(4)),
          Text(
            'Skor akhir kamu tersimpan di riwayat perangkat ini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDetails extends StatelessWidget {
  const _ResultDetails({
    required this.result,
    required this.insight,
    required this.onReview,
    required this.onRetry,
    required this.onHome,
  });

  final QuizResult result;
  final String insight;
  final VoidCallback onReview;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Ringkasan hasil',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: context.rs(4)),
          Text(
            '${result.settings.categoryLabel} • '
            '${result.settings.questionCount} soal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.mutedText,
            ),
          ),
          SizedBox(height: context.rs(16)),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= context.rs(380) ? 2 : 1;
              final gap = context.rs(9);
              final width = (constraints.maxWidth - gap * (columns - 1)) /
                  columns;
              final tiles = <Widget>[
                StatTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Benar',
                  value: '${result.correctAnswers}',
                  accent: palette.success,
                ),
                StatTile(
                  icon: Icons.cancel_outlined,
                  label: 'Salah',
                  value: '${result.wrongAnswers}',
                  accent: scheme.error,
                ),
                StatTile(
                  icon: Icons.remove_circle_outline_rounded,
                  label: 'Kosong',
                  value: '${result.unansweredQuestions}',
                  accent: palette.warning,
                ),
                StatTile(
                  icon: Icons.timer_outlined,
                  label: 'Waktu',
                  value: AppFormatters.duration(result.duration),
                  accent: scheme.primary,
                ),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final tile in tiles)
                    SizedBox(width: width, child: tile),
                ],
              );
            },
          ),
          SizedBox(height: context.rs(16)),
          Container(
            padding: EdgeInsets.all(context.rs(14)),
            decoration: BoxDecoration(
              color: palette.softPrimary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(context.rs(14)),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.tips_and_updates_outlined,
                  size: context.rs(19),
                  color: scheme.primary,
                ),
                SizedBox(width: context.rs(9)),
                Expanded(
                  child: Text(
                    insight,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.mutedText,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rs(20)),
          AppButton(
            key: const Key('result-review-button'),
            label: 'Lihat pembahasan',
            icon: Icons.menu_book_rounded,
            onPressed: onReview,
            fullWidth: true,
          ),
          SizedBox(height: context.rs(9)),
          AppButton(
            key: const Key('result-retry-button'),
            label: 'Main lagi',
            icon: Icons.replay_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: onRetry,
            fullWidth: true,
          ),
          SizedBox(height: context.rs(4)),
          AppButton(
            label: 'Kembali ke beranda',
            icon: Icons.home_outlined,
            variant: AppButtonVariant.ghost,
            onPressed: onHome,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
