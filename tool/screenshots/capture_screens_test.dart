// Captures the screenshots used in README.md.
//
// These are real widget renders of the app (same widget tree as the web build)
// at fixed logical sizes, produced by the Flutter test renderer. Run with:
//
//   flutter test tool/screenshots/capture_screens_test.dart --update-goldens
//
// The PNG files are written to doc/screenshots/ and committed with the project.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm5_christein/app.dart';
import 'package:uts_pm5_christein/data/data/question_bank.dart';
import 'package:uts_pm5_christein/state/theme_controller.dart';

import '../../test/support/test_support.dart';

const String _outDir = '../../doc/screenshots';

Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final weight in <String>[
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
  ]) {
    loader.addFont(
      rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
    );
  }
  await loader.load();
}

/// Material Icons is not registered by the test renderer, so load it from the
/// local Flutter SDK to keep icon glyphs in the screenshots.
Future<void> _loadMaterialIcons() async {
  final artifactDir = File(Platform.resolvedExecutable).parent.parent.parent;
  final candidates = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final String root
        when root.isNotEmpty)
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${artifactDir.path}/material_fonts/MaterialIcons-Regular.otf',
  ];

  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader('MaterialIcons')
      ..addFont(
        Future<ByteData>.value(
          bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
        ),
      );
    await loader.load();
    return;
  }

  fail('Font MaterialIcons tidak ditemukan di SDK Flutter.');
}

Future<TestHarness> _pumpApp(
  WidgetTester tester,
  Size size, {
  Map<String, String>? storedSettings,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final harness = TestHarness(
    questions: QuestionBank.all,
    random: Random(11),
    storedSettings: storedSettings,
  );
  await harness.initialize();
  addTearDown(harness.dispose);

  await tester.pumpWidget(harness.app());
  await tester.pumpAndSettle();
  return harness;
}

Future<void> _startQuiz(
  WidgetTester tester, {
  String name = 'Christein',
  int count = 10,
}) async {
  final field = find.byKey(const Key('name-field'));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, name);
  await tester.pumpAndSettle();

  final length = find.text('$count soal');
  await tester.ensureVisible(length);
  await tester.pumpAndSettle();
  await tester.tap(length);
  await tester.pumpAndSettle();

  await tapVisible(tester, find.byKey(const Key('home-start-button')));
}

Future<void> _answerCurrent(
  WidgetTester tester,
  TestHarness harness, {
  bool correct = true,
}) async {
  final question = harness.quiz.currentQuestion!;
  final index = correct
      ? question.correctIndex
      : (question.correctIndex + 1) % question.options.length;
  await tapVisible(tester, find.byKey(Key('quiz-option-$index')));
}

Future<void> _next(WidgetTester tester) async {
  await tapVisible(tester, find.byKey(const Key('quiz-next-button')));
}

Future<void> _expectGolden(WidgetTester tester, String name) {
  return expectLater(
    find.byType(KuisCendekiaApp),
    matchesGoldenFile('$_outDir/$name'),
  );
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    await _loadMaterialIcons();
  });

  testWidgets('01 home phone light', (tester) async {
    await _pumpApp(tester, const Size(390, 844));
    await _expectGolden(tester, '01-home-phone.png');
  });

  testWidgets('01b home phone form', (tester) async {
    await _pumpApp(tester, const Size(390, 844));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -560));
    await tester.pumpAndSettle();
    await _expectGolden(tester, '01b-home-phone-form.png');
  });

  testWidgets('02 quiz phone with selected answer', (tester) async {
    final harness = await _pumpApp(tester, const Size(390, 844));
    await _startQuiz(tester);
    await _answerCurrent(tester, harness);
    await _next(tester);
    await _answerCurrent(tester, harness, correct: false);
    await _next(tester);
    await _answerCurrent(tester, harness);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await _expectGolden(tester, '02-quiz-phone.png');
  });

  testWidgets('03 result phone then 04 review phone', (tester) async {
    final harness = await _pumpApp(tester, const Size(390, 844));
    await _startQuiz(tester);

    for (var index = 0; index < harness.quiz.totalQuestions; index++) {
      await _answerCurrent(tester, harness, correct: index != 4 && index != 8);
      await _next(tester);
    }

    await tester.pumpAndSettle();
    expect(harness.quiz.hasCompletedQuiz, isTrue);
    await _expectGolden(tester, '03-result-phone.png');

    await tapVisible(tester, find.byKey(const Key('result-review-button')));
    await tester.pumpAndSettle();
    await _expectGolden(tester, '04-review-phone.png');
  });

  testWidgets('05 home phone dark', (tester) async {
    await _pumpApp(
      tester,
      const Size(390, 844),
      storedSettings: <String, String>{
        ThemeController.storageKey: ThemeMode.dark.name,
      },
    );
    await _expectGolden(tester, '05-home-phone-dark.png');
  });

  testWidgets('06 home tablet', (tester) async {
    await _pumpApp(tester, const Size(834, 1112));
    await _expectGolden(tester, '06-home-tablet.png');
  });

  testWidgets('07 home desktop', (tester) async {
    await _pumpApp(tester, const Size(1280, 800));
    await _expectGolden(tester, '07-home-desktop.png');
  });

  testWidgets('08 quiz desktop', (tester) async {
    final harness = await _pumpApp(tester, const Size(1280, 800));
    await _startQuiz(tester);
    await _answerCurrent(tester, harness);
    await _next(tester);
    await _answerCurrent(tester, harness);
    await _expectGolden(tester, '08-quiz-desktop.png');
  });

  testWidgets('09 result desktop', (tester) async {
    final harness = await _pumpApp(tester, const Size(1280, 800));
    await _startQuiz(tester, count: 5);
    for (var index = 0; index < harness.quiz.totalQuestions; index++) {
      await _answerCurrent(tester, harness, correct: index != 2);
      await _next(tester);
    }
    await tester.pumpAndSettle();
    await _expectGolden(tester, '09-result-desktop.png');
  });
}
