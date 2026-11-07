import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm5_christein/state/theme_controller.dart';

import 'support/test_support.dart';

void main() {
  testWidgets('home validates the name and starts a quiz', (tester) async {
    final harness = await pumpQuizApp(tester);

    expect(find.byKey(const Key('home-compact-layout')), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('home-start-button')));
    expect(find.text('Masukkan namamu dulu, ya.'), findsOneWidget);
    expect(harness.quiz.hasActiveQuiz, isFalse);

    await startQuiz(tester, name: 'Rani');

    expect(harness.quiz.hasActiveQuiz, isTrue);
    expect(harness.quiz.playerName, 'Rani');
    expect(harness.quiz.totalQuestions, 4);
    expect(find.byKey(const Key('quiz-prompt')), findsOneWidget);
    expect(find.text('Soal 1 dari 4'), findsWidgets);
  });

  testWidgets(
    'progress survives rotation and navigating away then resuming',
    (tester) async {
      final harness = await pumpQuizApp(tester);
      await startQuiz(tester, name: 'Rani');

      final firstQuestion = harness.quiz.questions.first;
      final chosenIndex = firstQuestion.correctIndex;

      await tapVisible(
        tester,
        find.byKey(Key('quiz-option-$chosenIndex')),
      );
      expect(harness.quiz.answers[firstQuestion.id], chosenIndex);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);

      await tapVisible(tester, find.byKey(const Key('quiz-next-button')));
      expect(harness.quiz.currentIndex, 1);

      // Simulate rotating the device to landscape.
      tester.view.physicalSize = const Size(932, 430);
      await tester.pumpAndSettle();

      expect(harness.quiz.currentIndex, 1);
      expect(harness.quiz.answers[firstQuestion.id], chosenIndex);
      expect(find.byKey(const Key('quiz-prompt')), findsOneWidget);
      expect(find.byKey(const Key('quiz-next-button')), findsOneWidget);

      // Leave the quiz through the confirmation dialog.
      await tapVisible(tester, find.byTooltip('Kembali'));
      expect(find.text('Keluar dari kuis?'), findsOneWidget);
      await tapVisible(tester, find.text('Keluar'));

      expect(harness.quiz.hasActiveQuiz, isTrue);
      expect(find.byKey(const Key('home-resume-button')), findsOneWidget);

      // Resume and verify the same question and answer are still there.
      await tapVisible(tester, find.byKey(const Key('home-resume-button')));
      expect(harness.quiz.currentIndex, 1);
      expect(harness.quiz.answers[firstQuestion.id], chosenIndex);
      expect(
        find.text(harness.quiz.currentQuestion!.prompt),
        findsOneWidget,
      );
    },
  );

  testWidgets('completing a quiz shows a personalised result and review', (
    tester,
  ) async {
    final harness = await pumpQuizApp(tester);
    await startQuiz(tester, name: 'Rani');

    for (var index = 0; index < harness.quiz.totalQuestions; index++) {
      final question = harness.quiz.currentQuestion!;
      await tapVisible(
        tester,
        find.byKey(Key('quiz-option-${question.correctIndex}')),
      );
      await tapVisible(tester, find.byKey(const Key('quiz-next-button')));
    }

    expect(harness.quiz.hasActiveQuiz, isFalse);
    expect(harness.quiz.hasCompletedQuiz, isTrue);
    expect(harness.quiz.result?.score, 100);
    expect(harness.history.items, hasLength(1));
    expect(harness.history.bestScore, 100);

    expect(find.text('Rani'), findsOneWidget);
    expect(find.text('Luar biasa!'), findsOneWidget);
    expect(find.byKey(const Key('result-review-button')), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('result-review-button')));
    expect(find.text('Pembahasan'), findsWidgets);
    expect(find.text(testQuestions.first.prompt), findsOneWidget);
    expect(find.text(testQuestions.first.explanation), findsOneWidget);

    await tapVisible(tester, find.text('Salah (0)'));
    expect(find.text('Tidak ada soal di filter ini'), findsOneWidget);

    await tapVisible(tester, find.text('Tampilkan semua'));
    expect(find.byKey(const Key('review-card-1')), findsOneWidget);
  });

  testWidgets('theme can be switched to dark and is persisted', (tester) async {
    final harness = await pumpQuizApp(tester);

    await tester.tap(find.byKey(const Key('theme-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mode gelap'));
    await tester.pumpAndSettle();

    expect(harness.theme.mode, ThemeMode.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    final context = tester.element(find.byKey(const Key('name-field')));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      harness.settingsStore.read(ThemeController.storageKey),
      ThemeMode.dark.name,
    );

    final restored = ThemeController(harness.settingsStore);
    addTearDown(restored.dispose);
    expect(restored.mode, ThemeMode.dark);
  });

  testWidgets('home adapts to phone, tablet and desktop without overflow', (
    tester,
  ) async {
    await pumpQuizApp(tester);

    final sizes = <Size>[
      const Size(320, 568),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1280, 900),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Layout gagal pada ukuran ${size.width}x${size.height}',
      );
      expect(find.byKey(const Key('home-start-button')), findsOneWidget);
      expect(
        find.byKey(
          size.width >= 920
              ? const Key('home-wide-layout')
              : const Key('home-compact-layout'),
        ),
        findsOneWidget,
      );
    }
  });
}
