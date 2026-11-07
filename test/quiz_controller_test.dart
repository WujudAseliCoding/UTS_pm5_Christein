import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm5_christein/data/models/quiz_settings.dart';
import 'package:uts_pm5_christein/state/quiz_controller.dart';

import 'support/test_support.dart';

void main() {
  late QuizController controller;

  setUp(() {
    controller = QuizController(
      questionBank: testQuestions,
      random: Random(3),
      enableTicker: false,
    );
  });

  tearDown(() => controller.dispose());

  test('starts a quiz with trimmed name and clamps question count', () {
    controller.startQuiz(
      playerName: '  Rani Putri  ',
      settings: const QuizSettings(
        questionCount: 99,
        shuffleQuestions: false,
        shuffleOptions: false,
      ),
    );

    expect(controller.status, QuizStatus.inProgress);
    expect(controller.hasActiveQuiz, isTrue);
    expect(controller.playerName, 'Rani Putri');
    expect(controller.totalQuestions, testQuestions.length);
    expect(controller.settings.questionCount, testQuestions.length);
    expect(controller.currentIndex, 0);
    expect(controller.answeredCount, 0);
  });

  test('rejects an empty name', () {
    expect(
      () => controller.startQuiz(
        playerName: '   ',
        settings: const QuizSettings(),
      ),
      throwsArgumentError,
    );
  });

  test('filters by category and never exceeds the available pool', () {
    controller.startQuiz(
      playerName: 'Rani',
      settings: const QuizSettings(
        category: QuizCategory.flutter,
        questionCount: 50,
        shuffleQuestions: false,
        shuffleOptions: false,
      ),
    );

    expect(controller.totalQuestions, 2);
    expect(
      controller.questions.every(
        (question) => question.category == QuizCategory.flutter,
      ),
      isTrue,
    );
    expect(controller.availableCount(QuizCategory.flutter), 2);
    expect(controller.availableCount(QuizCategory.dart), 1);
    expect(controller.availableCount(null), 4);
  });

  test('answers survive question navigation and can be cleared', () {
    controller.startQuiz(
      playerName: 'Rani',
      settings: const QuizSettings(
        shuffleQuestions: false,
        shuffleOptions: false,
      ),
    );

    final firstId = controller.questions.first.id;
    controller.selectAnswer(2);
    expect(controller.answers[firstId], 2);

    controller.nextQuestion();
    expect(controller.currentIndex, 1);
    controller.previousQuestion();

    expect(controller.currentIndex, 0);
    expect(controller.selectedIndex, 2);
    expect(controller.answeredCount, 1);

    controller.clearCurrentAnswer();
    expect(controller.selectedIndex, isNull);
    expect(controller.isAnswered(controller.currentQuestion!), isFalse);

    controller.goToQuestion(3);
    expect(controller.currentIndex, 3);
    controller.goToQuestion(99);
    expect(controller.currentIndex, 3);
  });

  test('computes score, review entries and empty answers correctly', () {
    controller.startQuiz(
      playerName: 'Rani',
      settings: const QuizSettings(
        questionCount: 4,
        shuffleQuestions: false,
        shuffleOptions: false,
      ),
    );

    // Question 1: correct.
    controller.selectAnswer(controller.currentQuestion!.correctIndex);
    controller.nextQuestion();

    // Question 2: wrong.
    final second = controller.currentQuestion!;
    controller.selectAnswer(
      second.options.indexed
          .firstWhere((item) => item.$1 != second.correctIndex)
          .$1,
    );
    controller.nextQuestion();

    // Question 3: deliberately unanswered.
    controller.nextQuestion();

    // Question 4: correct.
    controller.selectAnswer(controller.currentQuestion!.correctIndex);

    expect(controller.answeredCount, 3);
    expect(controller.finishQuiz(), isTrue);
    expect(controller.finishQuiz(), isFalse);
    expect(controller.status, QuizStatus.finished);

    final result = controller.result!;
    expect(result.playerName, 'Rani');
    expect(result.totalQuestions, 4);
    expect(result.correctAnswers, 2);
    expect(result.answeredQuestions, 3);
    expect(result.wrongAnswers, 1);
    expect(result.unansweredQuestions, 1);
    expect(result.score, 50);
    expect(controller.reviewEntries, hasLength(4));
    expect(controller.reviewEntries[0].isCorrect, isTrue);
    expect(controller.reviewEntries[1].isWrong, isTrue);
    expect(controller.reviewEntries[2].isAnswered, isFalse);
    expect(controller.reviewEntries[3].isCorrect, isTrue);
  });

  test('shuffling options preserves the correct answer mapping', () {
    controller.startQuiz(
      playerName: 'Rani',
      settings: const QuizSettings(
        shuffleQuestions: true,
        shuffleOptions: true,
      ),
    );

    for (final question in controller.questions) {
      final source = question.source;
      expect(
        question.options.toSet(),
        source.options.toSet(),
      );
      expect(question.correctIndex, inInclusiveRange(0, 3));
      expect(
        question.correctAnswer,
        source.options[source.correctIndex],
      );
    }
  });

  test('reset clears progress but keeps convenient last settings', () {
    controller.startQuiz(
      playerName: 'Rani',
      settings: const QuizSettings(
        category: QuizCategory.dart,
        questionCount: 1,
        shuffleQuestions: false,
        shuffleOptions: false,
      ),
    );
    controller.selectAnswer(0);

    controller.resetSession();

    expect(controller.status, QuizStatus.idle);
    expect(controller.hasActiveQuiz, isFalse);
    expect(controller.totalQuestions, 0);
    expect(controller.answeredCount, 0);
    expect(controller.result, isNull);
    expect(controller.lastPlayerName, 'Rani');
    expect(controller.lastSettings.category, QuizCategory.dart);
    expect(controller.lastSettings.questionCount, 1);
  });
}
