import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm5_christein/app.dart';
import 'package:uts_pm5_christein/data/models/question.dart';
import 'package:uts_pm5_christein/data/models/quiz_settings.dart';
import 'package:uts_pm5_christein/services/history_repository.dart';
import 'package:uts_pm5_christein/services/settings_store.dart';
import 'package:uts_pm5_christein/state/history_controller.dart';
import 'package:uts_pm5_christein/state/quiz_controller.dart';
import 'package:uts_pm5_christein/state/theme_controller.dart';

const List<Question> testQuestions = <Question>[
  Question(
    id: 'test-flutter-1',
    category: QuizCategory.flutter,
    prompt: 'Widget apa yang menyusun anak secara vertikal?',
    options: <String>['Row', 'Column', 'Stack', 'Wrap'],
    correctIndex: 1,
    explanation: 'Column menyusun anak dari atas ke bawah.',
  ),
  Question(
    id: 'test-flutter-2',
    category: QuizCategory.flutter,
    prompt: 'Method apa yang memicu rebuild pada State?',
    options: <String>['initState', 'build', 'setState', 'dispose'],
    correctIndex: 2,
    explanation: 'setState memberi tahu Flutter untuk membangun ulang UI.',
  ),
  Question(
    id: 'test-dart-1',
    category: QuizCategory.dart,
    prompt: 'Kata kunci untuk nilai yang tidak berubah adalah ...',
    options: <String>['final', 'var', 'dynamic', 'late'],
    correctIndex: 0,
    explanation: 'final menetapkan nilai satu kali setelah inisialisasi.',
  ),
  Question(
    id: 'test-umum-1',
    category: QuizCategory.general,
    prompt: 'Ibu kota Jepang adalah ...',
    options: <String>['Osaka', 'Kyoto', 'Tokyo', 'Nagoya'],
    correctIndex: 2,
    explanation: 'Tokyo adalah ibu kota Jepang.',
  ),
];

class TestHarness {
  TestHarness({
    List<Question>? questions,
    Random? random,
    Map<String, String>? storedSettings,
  }) : settingsStore = InMemorySettingsStore(storedSettings),
       historyRepository = InMemoryHistoryRepository(),
       quiz = QuizController(
         questionBank: questions ?? testQuestions,
         random: random ?? Random(7),
         enableTicker: false,
       ) {
    theme = ThemeController(settingsStore);
    history = HistoryController(historyRepository);
  }

  final InMemorySettingsStore settingsStore;
  final InMemoryHistoryRepository historyRepository;
  final QuizController quiz;
  late final ThemeController theme;
  late final HistoryController history;

  Future<void> initialize() => history.load();

  Widget app() => KuisCendekiaApp(
    themeController: theme,
    historyController: history,
    quizController: quiz,
  );

  void dispose() {
    quiz.dispose();
    theme.dispose();
    history.dispose();
  }
}

Future<TestHarness> pumpQuizApp(
  WidgetTester tester, {
  Size size = const Size(430, 932),
  List<Question>? questions,
  Map<String, String>? storedSettings,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final harness = TestHarness(
    questions: questions,
    storedSettings: storedSettings,
  );
  await harness.initialize();
  addTearDown(harness.dispose);

  await tester.pumpWidget(harness.app());
  await tester.pumpAndSettle();
  return harness;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> startQuiz(WidgetTester tester, {String name = 'Rani'}) async {
  final field = find.byKey(const Key('name-field'));
  await tester.ensureVisible(field);
  await tester.enterText(field, name);
  await tester.pumpAndSettle();
  await tapVisible(tester, find.byKey(const Key('home-start-button')));
}
