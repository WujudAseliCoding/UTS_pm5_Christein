import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routing/app_router.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../data/models/question.dart';
import '../state/history_controller.dart';
import '../state/quiz_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/app_components.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/option_tile.dart';
import '../widgets/quiz_progress.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isFinishing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _selectAnswer(int index) {
    context.read<QuizController>().selectAnswer(index);
  }

  void _goToQuestion(int index) {
    final quiz = context.read<QuizController>();
    quiz.goToQuestion(index);
    _scrollToTop();
  }

  void _next() {
    final quiz = context.read<QuizController>();
    if (quiz.isLastQuestion) {
      _requestFinish();
      return;
    }
    quiz.nextQuestion();
    _scrollToTop();
  }

  void _previous() {
    context.read<QuizController>().previousQuestion();
    _scrollToTop();
  }

  Future<void> _requestExit() async {
    final quiz = context.read<QuizController>();
    if (!quiz.hasActiveQuiz) {
      Navigator.of(context).pop();
      return;
    }
    final exit = await showConfirmDialog(
      context,
      title: 'Keluar dari kuis?',
      message:
          'Progres jawabanmu tersimpan selama aplikasi berjalan. '
          'Kamu bisa melanjutkan kuis dari halaman utama.',
      confirmLabel: 'Keluar',
      cancelLabel: 'Lanjutkan kuis',
      icon: Icons.exit_to_app_rounded,
      destructive: true,
    );
    if (!exit || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _requestFinish() async {
    final quiz = context.read<QuizController>();
    if (!quiz.hasActiveQuiz || _isFinishing) return;

    final remaining = quiz.totalQuestions - quiz.answeredCount;
    if (remaining > 0) {
      final confirm = await showConfirmDialog(
        context,
        title: 'Selesaikan sekarang?',
        message:
            'Masih ada $remaining soal yang belum dijawab. '
            'Soal kosong akan dihitung sebagai jawaban salah.',
        confirmLabel: 'Selesaikan',
        cancelLabel: 'Periksa lagi',
        icon: Icons.flag_outlined,
      );
      if (!confirm || !mounted) return;
    }

    await _finishQuiz();
  }

  Future<void> _finishQuiz() async {
    if (!mounted) return;
    setState(() => _isFinishing = true);
    final quiz = context.read<QuizController>();
    final history = context.read<HistoryController>();

    final finished = quiz.finishQuiz();
    if (!finished) {
      if (mounted) setState(() => _isFinishing = false);
      return;
    }

    final result = quiz.result;
    if (result != null) {
      await history.record(result);
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.result);
  }

  void _openQuestionPalette() {
    final quiz = context.read<QuizController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.rs(22),
                context.rs(4),
                context.rs(22),
                context.rs(24) +
                    MediaQuery.paddingOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Daftar soal',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                  SizedBox(height: context.rs(4)),
                  Text(
                    'Pilih nomor untuk berpindah soal.',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  SizedBox(height: context.rs(16)),
                  QuizSummaryCard(
                    answered: quiz.answeredCount,
                    total: quiz.totalQuestions,
                    currentNumber: quiz.currentNumber,
                    elapsed: quiz.elapsed,
                  ),
                  SizedBox(height: context.rs(16)),
                  QuestionNavigatorGrid(
                    total: quiz.totalQuestions,
                    currentIndex: quiz.currentIndex,
                    isAnsweredAt: quiz.isAnsweredAt,
                    onSelected: (index) {
                      Navigator.of(sheetContext).pop();
                      _goToQuestion(index);
                    },
                  ),
                  SizedBox(height: context.rs(14)),
                  const _QuestionLegend(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();

    if (!quiz.hasActiveQuiz) {
      return _QuizUnavailable(
        quiz: quiz,
        onBack: () => Navigator.of(context).maybePop(),
      );
    }

    final question = quiz.currentQuestion!;
    final wide = MediaQuery.sizeOf(context).width >= context.rs(900);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _requestExit();
      },
      child: PageScaffold(
        maxWidth: 1180,
        header: AppTopBar(
          title: 'Soal ${quiz.currentNumber} dari ${quiz.totalQuestions}',
          subtitle: '${quiz.playerName} • ${quiz.settings.categoryLabel}',
          showBack: true,
          onBack: _requestExit,
          showThemeButton: false,
          actions: <Widget>[QuizTimerChip(elapsed: quiz.elapsed)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!wide) ...<Widget>[
              AppCard(
                showShadow: false,
                padding: EdgeInsets.all(context.rs(15)),
                child: QuizSummaryCard(
                  answered: quiz.answeredCount,
                  total: quiz.totalQuestions,
                  currentNumber: quiz.currentNumber,
                  elapsed: quiz.elapsed,
                ),
              ),
              SizedBox(height: context.rs(12)),
            ],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildQuestionArea(quiz, question),
                        SizedBox(height: context.rs(12)),
                        _buildNavigationRow(quiz),
                      ],
                    ),
                  ),
                  SizedBox(width: context.rs(18)),
                  SizedBox(
                    width: context.rs(330),
                    child: _buildSidebar(quiz, question),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildQuestionArea(quiz, question),
                  SizedBox(height: context.rs(12)),
                  _MobileActions(
                    quiz: quiz,
                    isFinishing: _isFinishing,
                    onPrevious: _previous,
                    onNext: _next,
                    onPalette: _openQuestionPalette,
                    onFinish: _requestFinish,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionArea(QuizController quiz, QuizQuestion question) {
    final selected = quiz.selectedIndex;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppBadge(
                label: question.category.label,
                icon: Icons.sell_outlined,
              ),
              const Spacer(),
              Text(
                '${quiz.currentNumber}/${quiz.totalQuestions}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(16)),
          Text(
            question.prompt,
            key: const Key('quiz-prompt'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: context.responsive(
                compact: context.rs(21),
                medium: context.rs(22),
                expanded: context.rs(23),
              ),
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.rs(18)),
          for (var index = 0; index < question.options.length; index++) ...<Widget>[
            OptionTile(
              key: Key('quiz-option-$index'),
              index: index,
              text: question.options[index],
              state: selected == index
                  ? OptionVisualState.selected
                  : OptionVisualState.idle,
              onTap: () => _selectAnswer(index),
            ),
            if (index != question.options.length - 1)
              SizedBox(height: context.rs(9)),
          ],
          SizedBox(height: context.rs(14)),
          Row(
            children: <Widget>[
              Icon(
                selected == null
                    ? Icons.touch_app_outlined
                    : Icons.check_circle_outline_rounded,
                size: context.rs(16),
                color: selected == null
                    ? context.palette.mutedText
                    : context.palette.success,
              ),
              SizedBox(width: context.rs(6)),
              Expanded(
                child: Text(
                  selected == null
                      ? 'Ketuk salah satu opsi untuk menjawab.'
                      : 'Jawaban tersimpan. Kamu masih bisa mengubahnya.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ),
              if (selected != null)
                TextButton(
                  onPressed: () =>
                      context.read<QuizController>().clearCurrentAnswer(),
                  child: const Text('Hapus'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(QuizController quiz) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppButton(
            label: 'Sebelumnya',
            icon: Icons.arrow_back_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: quiz.isFirstQuestion ? null : _previous,
            compact: true,
          ),
        ),
        SizedBox(width: context.rs(10)),
        Expanded(
          child: AppButton(
            key: const Key('quiz-next-button'),
            label: quiz.isLastQuestion ? 'Selesai' : 'Berikutnya',
            icon: quiz.isLastQuestion
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            onPressed: _isFinishing
                ? null
                : quiz.isLastQuestion
                ? _requestFinish
                : _next,
            isLoading: _isFinishing,
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(QuizController quiz, QuizQuestion question) {
    return AppCard(
      showShadow: false,
      padding: EdgeInsets.all(context.rs(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QuizSummaryCard(
            answered: quiz.answeredCount,
            total: quiz.totalQuestions,
            currentNumber: quiz.currentNumber,
            elapsed: quiz.elapsed,
          ),
          Divider(height: context.rs(30)),
          Text(
            'Navigasi soal',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: context.rs(10)),
          QuestionNavigatorGrid(
            total: quiz.totalQuestions,
            currentIndex: quiz.currentIndex,
            isAnsweredAt: quiz.isAnsweredAt,
            onSelected: _goToQuestion,
            compact: true,
          ),
          SizedBox(height: context.rs(12)),
          const _QuestionLegend(),
          SizedBox(height: context.rs(18)),
          _QuestionMeta(question: question),
          SizedBox(height: context.rs(16)),
          AppButton(
            key: const Key('quiz-sidebar-finish-button'),
            label: 'Selesaikan kuis',
            icon: Icons.flag_rounded,
            onPressed: _isFinishing ? null : _requestFinish,
            isLoading: _isFinishing,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _MobileActions extends StatelessWidget {
  const _MobileActions({
    required this.quiz,
    required this.isFinishing,
    required this.onPrevious,
    required this.onNext,
    required this.onPalette,
    required this.onFinish,
  });

  final QuizController quiz;
  final bool isFinishing;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPalette;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: 'Sebelumnya',
                icon: Icons.arrow_back_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: quiz.isFirstQuestion ? null : onPrevious,
                compact: true,
              ),
            ),
            SizedBox(width: context.rs(9)),
            Expanded(
              child: AppButton(
                key: const Key('quiz-next-button'),
                label: quiz.isLastQuestion ? 'Selesai' : 'Berikutnya',
                icon: quiz.isLastQuestion
                    ? Icons.flag_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: isFinishing
                    ? null
                    : quiz.isLastQuestion
                    ? onFinish
                    : onNext,
                isLoading: isFinishing,
                compact: true,
              ),
            ),
          ],
        ),
        SizedBox(height: context.rs(9)),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: 'Daftar soal',
                icon: Icons.grid_view_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: onPalette,
                compact: true,
              ),
            ),
            SizedBox(width: context.rs(9)),
            Expanded(
              child: AppButton(
                key: const Key('quiz-finish-button'),
                label: 'Selesai sekarang',
                icon: Icons.flag_outlined,
                variant: AppButtonVariant.ghost,
                onPressed: isFinishing ? null : onFinish,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuestionMeta extends StatelessWidget {
  const _QuestionMeta({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(12)),
      decoration: BoxDecoration(
        color: context.palette.optionSurface,
        borderRadius: BorderRadius.circular(context.rs(13)),
        border: Border.all(color: context.palette.optionBorder),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lightbulb_outline_rounded,
            size: context.rs(17),
            color: context.palette.warning,
          ),
          SizedBox(width: context.rs(8)),
          Expanded(
            child: Text(
              'Pembahasan muncul setelah kuis selesai.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionLegend extends StatelessWidget {
  const _QuestionLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.rs(12),
      runSpacing: context.rs(6),
      children: <Widget>[
        _LegendDot(
          color: Theme.of(context).colorScheme.primary,
          label: 'Terjawab',
          filled: true,
        ),
        _LegendDot(
          color: Theme.of(context).colorScheme.primary,
          label: 'Saat ini',
          filled: false,
        ),
        _LegendDot(
          color: context.palette.optionBorder,
          label: 'Kosong',
          filled: false,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.filled,
  });

  final Color color;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: context.rs(11),
          height: context.rs(11),
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.6),
            borderRadius: BorderRadius.circular(context.rs(3)),
          ),
        ),
        SizedBox(width: context.rs(5)),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.palette.mutedText,
            fontSize: context.rs(10.5),
          ),
        ),
      ],
    );
  }
}

class _QuizUnavailable extends StatelessWidget {
  const _QuizUnavailable({required this.quiz, required this.onBack});

  final QuizController quiz;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hasResult = quiz.result != null;
    return PageScaffold(
      maxWidth: 900,
      header: AppTopBar(
        title: 'Kuis',
        showBack: true,
        onBack: onBack,
      ),
      child: AppCard(
        child: EmptyState(
          imageAsset: hasResult
              ? 'assets/images/trophy.svg'
              : 'assets/images/hero_quiz.svg',
          imageMaxWidth: context.rs(220),
          title: hasResult ? 'Kuis sudah selesai' : 'Belum ada kuis aktif',
          message: hasResult
              ? 'Buka halaman hasil untuk melihat skor dan pembahasan.'
              : 'Mulai kuis baru dari halaman utama untuk melihat soal di sini.',
          action: AppButton(
            label: hasResult ? 'Lihat hasil' : 'Kembali ke beranda',
            icon: hasResult
                ? Icons.emoji_events_rounded
                : Icons.home_rounded,
            onPressed: hasResult
                ? () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.result)
                : onBack,
          ),
        ),
      ),
    );
  }
}
