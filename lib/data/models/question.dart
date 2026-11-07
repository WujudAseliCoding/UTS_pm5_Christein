import 'dart:math';

import 'quiz_settings.dart';

/// A question in the local bank. Never persisted to a database.
class Question {
  const Question({
    required this.id,
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final QuizCategory category;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// A question prepared for one quiz attempt.
///
/// Options may be shuffled, so the correct answer is tracked separately from
/// the source question.
class QuizQuestion {
  const QuizQuestion({
    required this.source,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromSource(
    Question source, {
    required Random random,
    bool shuffleOptions = true,
  }) {
    final order = List<int>.generate(source.options.length, (index) => index);
    if (shuffleOptions) order.shuffle(random);

    return QuizQuestion(
      source: source,
      options: <String>[for (final index in order) source.options[index]],
      correctIndex: order.indexOf(source.correctIndex),
    );
  }

  final Question source;
  final List<String> options;
  final int correctIndex;

  String get id => source.id;
  String get prompt => source.prompt;
  QuizCategory get category => source.category;
  String get explanation => source.explanation;
  String get correctAnswer => options[correctIndex];
}

/// A snapshot of one question after the quiz is completed.
class ReviewEntry {
  const ReviewEntry({required this.question, required this.selectedIndex});

  final QuizQuestion question;
  final int? selectedIndex;

  bool get isAnswered => selectedIndex != null;
  bool get isCorrect => selectedIndex == question.correctIndex;
  bool get isWrong => isAnswered && !isCorrect;
  String? get selectedAnswer =>
      selectedIndex == null ? null : question.options[selectedIndex!];
}

/// Result of a completed attempt, also used by the local history store.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.playerName,
    required this.settings,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answeredQuestions,
    required this.duration,
    required this.completedAt,
  });

  final String id;
  final String playerName;
  final QuizSettings settings;
  final int totalQuestions;
  final int correctAnswers;
  final int answeredQuestions;
  final Duration duration;
  final DateTime completedAt;

  int get wrongAnswers => answeredQuestions - correctAnswers;
  int get unansweredQuestions => totalQuestions - answeredQuestions;

  double get scorePercentage {
    if (totalQuestions == 0) return 0;
    return correctAnswers / totalQuestions * 100;
  }

  int get score => (scorePercentage.round()).clamp(0, 100);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'playerName': playerName,
    'settings': settings.toJson(),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'answeredQuestions': answeredQuestions,
    'durationSeconds': duration.inSeconds,
    'completedAt': completedAt.toIso8601String(),
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      playerName: json['playerName'] as String,
      settings: QuizSettings.fromJson(
        Map<String, dynamic>.from(json['settings'] as Map),
      ),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      answeredQuestions: (json['answeredQuestions'] as num).toInt(),
      duration: Duration(
        seconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      ),
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
