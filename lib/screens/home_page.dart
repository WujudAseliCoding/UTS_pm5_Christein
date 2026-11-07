import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/routing/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../data/models/quiz_settings.dart';
import '../state/history_controller.dart';
import '../state/quiz_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/app_components.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/category_selector.dart';
import '../widgets/dialogs.dart';
import '../widgets/history_panel.dart';
import '../widgets/name_field.dart';
import '../widgets/quiz_length_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  late final TextEditingController _nameController;
  late QuizCategory? _category;
  late int _questionCount;

  @override
  void initState() {
    super.initState();
    final quiz = context.read<QuizController>();
    _nameController = TextEditingController(text: quiz.lastPlayerName);
    _category = quiz.lastSettings.category;
    _questionCount = quiz.lastSettings.questionCount;
    _normalizeCount(quiz.availableCount(_category));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _normalizeCount(int maxCount) {
    final options = QuizLengthSelector.optionsFor(maxCount);
    if (!options.contains(_questionCount)) {
      _questionCount = options.last;
    }
  }

  void _onCategoryChanged(QuizCategory? category) {
    final maxCount = context.read<QuizController>().availableCount(category);
    setState(() {
      _category = category;
      _normalizeCount(maxCount);
    });
  }

  Future<void> _startQuiz() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final quiz = context.read<QuizController>();
    if (quiz.hasActiveQuiz) {
      final replace = await showConfirmDialog(
        context,
        title: 'Ganti kuis yang sedang berjalan?',
        message:
            'Progres kuis ${quiz.playerName} yang belum selesai akan diganti '
            'dengan kuis baru.',
        confirmLabel: 'Mulai baru',
        cancelLabel: 'Lanjutkan kuis',
        destructive: true,
        icon: Icons.restart_alt_rounded,
      );
      if (!replace || !mounted) return;
    }

    quiz.startQuiz(
      playerName: _nameController.text,
      settings: QuizSettings(
        category: _category,
        questionCount: _questionCount,
      ),
    );

    await Navigator.of(context).pushNamed(AppRoutes.quiz);
  }

  Future<void> _resumeQuiz() async {
    final quiz = context.read<QuizController>();
    if (!quiz.hasActiveQuiz) return;
    await Navigator.of(context).pushNamed(AppRoutes.quiz);
  }

  Future<void> _discardActiveQuiz() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan kuis?',
      message:
          'Semua jawaban pada kuis yang sedang berjalan akan dihapus. '
          'Riwayat skor yang sudah selesai tidak terpengaruh.',
      confirmLabel: 'Batalkan kuis',
      cancelLabel: 'Kembali',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    context.read<QuizController>().resetSession();
    showAppSnackBar(context, 'Kuis berjalan dibatalkan.', icon: Icons.check_rounded);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus riwayat skor?',
      message:
          'Seluruh riwayat skor pada perangkat ini akan dihapus permanen. '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus semua',
      cancelLabel: 'Batal',
      destructive: true,
      icon: Icons.delete_sweep_outlined,
    );
    if (!confirmed || !mounted) return;
    await context.read<HistoryController>().clear();
    if (!mounted) return;
    showAppSnackBar(context, 'Riwayat skor dihapus.', icon: Icons.check_rounded);
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Kuis Cendekia',
      applicationVersion: '1.0.0',
      applicationIcon: const AppLogo(),
      applicationLegalese: 'Proyek UTS Pemrograman Mobile',
      children: <Widget>[
        SizedBox(height: context.rs(12)),
        const Text(
          'Kuis pilihan ganda dengan 30 pertanyaan lokal, pembahasan, '
          'riwayat skor, serta tema terang dan gelap.',
        ),
        SizedBox(height: context.rs(8)),
        const Text(
          'Font: Plus Jakarta Sans (SIL Open Font License 1.1). '
          'Ilustrasi: aset SVG orisinal untuk proyek ini.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final history = context.watch<HistoryController>();

    return PageScaffold(
      maxWidth: 1240,
      header: AppTopBar(
        actions: <Widget>[
          AppIconButton(
            icon: Icons.info_outline_rounded,
            tooltip: 'Tentang aplikasi',
            onPressed: _showAbout,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (quiz.hasActiveQuiz) ...<Widget>[
            _ResumeCard(
              quiz: quiz,
              onResume: _resumeQuiz,
              onDiscard: _discardActiveQuiz,
            ),
            SizedBox(height: context.rs(18)),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= context.rs(920);
              final hero = _HeroSection(compact: !wide);
              final setup = _SetupCard(
                formKey: _formKey,
                nameController: _nameController,
                nameFocus: _nameFocus,
                category: _category,
                questionCount: _questionCount,
                maxCount: quiz.availableCount(_category),
                onCategoryChanged: _onCategoryChanged,
                onCountChanged: (value) => setState(() => _questionCount = value),
                onStart: _startQuiz,
                onSubmitted: _startQuiz,
              );

              if (!wide) {
                return Column(
                  key: const Key('home-compact-layout'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    hero,
                    SizedBox(height: context.rs(22)),
                    setup,
                  ],
                );
              }

              return Row(
                key: const Key('home-wide-layout'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 11, child: hero),
                  SizedBox(width: context.rs(34)),
                  Expanded(flex: 9, child: setup),
                ],
              );
            },
          ),
          SizedBox(height: context.rs(34)),
          const _HowToPlay(),
          SizedBox(height: context.rs(34)),
          HistoryPanel(
            items: history.items,
            bestScore: history.bestScore,
            onClear: _clearHistory,
          ),
          SizedBox(height: context.rs(26)),
          const _Footer(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: context.rs(8),
          runSpacing: context.rs(8),
          children: <Widget>[
            const AppBadge(
              label: '30 soal lokal',
              icon: Icons.quiz_outlined,
            ),
            AppBadge(
              label: '3 kategori',
              icon: Icons.category_outlined,
              foreground: palette.warning,
              background: palette.softWarning,
            ),
            AppBadge(
              label: 'Tanpa database',
              icon: Icons.offline_bolt_outlined,
              foreground: palette.success,
              background: palette.softSuccess,
            ),
          ],
        ),
        SizedBox(height: context.rs(16)),
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              const TextSpan(text: 'Uji wawasanmu,\n'),
              TextSpan(
                text: 'satu jawaban',
                style: TextStyle(color: scheme.primary),
              ),
              const TextSpan(text: ' setiap waktu.'),
            ],
          ),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: compact ? context.rs(34) : context.rs(40),
            height: 1.12,
          ),
        ),
        SizedBox(height: context.rs(12)),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.rs(520)),
          child: Text(
            'Pilih topik, masukkan namamu, lalu jawab soal pilihan ganda. '
            'Skor dan pembahasan langsung tersedia di akhir kuis.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.mutedText,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: context.rs(18)),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: compact ? context.rs(300) : context.rs(440),
            ),
            child: SvgPicture.asset(
              'assets/images/hero_quiz.svg',
              fit: BoxFit.contain,
              semanticsLabel:
                  'Ilustrasi kartu kuis dengan jawaban benar dan lampu ide',
            ),
          ),
        ),
        SizedBox(height: context.rs(8)),
        Wrap(
          spacing: context.rs(14),
          runSpacing: context.rs(8),
          children: const <Widget>[
            _HeroPoint(icon: Icons.touch_app_rounded, label: 'Mudah dipakai'),
            _HeroPoint(icon: Icons.insights_rounded, label: 'Skor instan'),
            _HeroPoint(
              icon: Icons.menu_book_rounded,
              label: 'Ada pembahasan',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPoint extends StatelessWidget {
  const _HeroPoint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: context.rs(17), color: context.palette.success),
        SizedBox(width: context.rs(6)),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ],
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.formKey,
    required this.nameController,
    required this.nameFocus,
    required this.category,
    required this.questionCount,
    required this.maxCount,
    required this.onCategoryChanged,
    required this.onCountChanged,
    required this.onStart,
    required this.onSubmitted,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final QuizCategory? category;
  final int questionCount;
  final int maxCount;
  final ValueChanged<QuizCategory?> onCategoryChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: context.rs(42),
                  height: context.rs(42),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(context.rs(13)),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: context.rs(24),
                  ),
                ),
                SizedBox(width: context.rs(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Mulai kuis baru',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Atur sesuai keinginanmu',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(20)),
            NameField(
              controller: nameController,
              focusNode: nameFocus,
              onSubmitted: (_) => onSubmitted(),
            ),
            SizedBox(height: context.rs(18)),
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: context.rs(8)),
            CategorySelector(
              selected: category,
              onChanged: onCategoryChanged,
              countForCategory: (value) =>
                  context.read<QuizController>().availableCount(value),
            ),
            SizedBox(height: context.rs(18)),
            Wrap(
              spacing: context.rs(12),
              runSpacing: context.rs(4),
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'Jumlah soal',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '$maxCount soal tersedia',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(8)),
            QuizLengthSelector(
              selected: questionCount,
              maxCount: maxCount,
              onChanged: onCountChanged,
            ),
            SizedBox(height: context.rs(18)),
            Wrap(
              spacing: context.rs(14),
              runSpacing: context.rs(6),
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.timer_outlined,
                      size: context.rs(16),
                      color: palette.mutedText,
                    ),
                    SizedBox(width: context.rs(6)),
                    Flexible(
                      child: Text(
                        'Tanpa batas waktu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.shuffle_rounded,
                      size: context.rs(16),
                      color: palette.mutedText,
                    ),
                    SizedBox(width: context.rs(6)),
                    Flexible(
                      child: Text(
                        'Soal & opsi diacak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.rs(20)),
            AppButton(
              key: const Key('home-start-button'),
              label: 'Mulai kuis',
              icon: Icons.arrow_forward_rounded,
              onPressed: onStart,
              fullWidth: true,
            ),
            SizedBox(height: context.rs(10)),
            Center(
              child: Text(
                'Nama akan ditampilkan pada hasil akhir.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.quiz,
    required this.onResume,
    required this.onDiscard,
  });

  final QuizController quiz;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

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
        ],
      ),
      borderColor: scheme.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: context.rs(40),
                height: context.rs(40),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(context.rs(13)),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: scheme.onPrimary,
                  size: context.rs(23),
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Kuis ${quiz.playerName} belum selesai',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: context.rs(2)),
                    Text(
                      '${quiz.answeredCount} dari ${quiz.totalQuestions} soal '
                      'sudah dijawab • ${quiz.settings.categoryLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: quiz.answeredProgress,
              minHeight: context.rs(7),
              backgroundColor: scheme.surface,
            ),
          ),
          SizedBox(height: context.rs(12)),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: 'Batalkan',
                  variant: AppButtonVariant.ghost,
                  onPressed: onDiscard,
                  compact: true,
                ),
              ),
              SizedBox(width: context.rs(8)),
              Expanded(
                child: AppButton(
                  key: const Key('home-resume-button'),
                  label: 'Lanjutkan',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onResume,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowToPlay extends StatelessWidget {
  const _HowToPlay();

  @override
  Widget build(BuildContext context) {
    const steps = <(IconData, String, String)>[
      (
        Icons.tune_rounded,
        'Pilih & isi nama',
        'Tentukan kategori, jumlah soal, lalu tulis namamu.',
      ),
      (
        Icons.flag_rounded,
        'Jawab dengan tenang',
        'Pindah soal bebas, jawaban tersimpan selama sesi.',
      ),
      (
        Icons.analytics_rounded,
        'Lihat skor & pembahasan',
        'Skor akhir, rincian jawaban, dan penjelasan tersedia.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(
          title: 'Cara main',
          subtitle: 'Tiga langkah, langsung mulai',
          leadingIcon: Icons.route_rounded,
        ),
        SizedBox(height: context.rs(14)),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= context.rs(760)
                ? 3
                : 1;
            final gap = context.rs(10);
            final width = (constraints.maxWidth - gap * (columns - 1)) /
                columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (var index = 0; index < steps.length; index++)
                  SizedBox(
                    width: width,
                    child: AppCard(
                      showShadow: false,
                      padding: EdgeInsets.all(context.rs(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: context.rs(36),
                            height: context.rs(36),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.palette.softPrimary,
                              borderRadius: BorderRadius.circular(
                                context.rs(11),
                              ),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          SizedBox(width: context.rs(11)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  steps[index].$2,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall,
                                ),
                                SizedBox(height: context.rs(3)),
                                Text(
                                  steps[index].$3,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.palette.mutedText,
                                        height: 1.45,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(color: context.palette.cardBorder),
        SizedBox(height: context.rs(14)),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: context.rs(6),
          children: <Widget>[
            Text(
              'Kuis Cendekia • v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            Text(
              '•',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            Text(
              'Data lokal, tanpa database',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
