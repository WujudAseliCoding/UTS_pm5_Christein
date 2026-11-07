import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/models/question.dart';
import '../data/models/quiz_settings.dart';

enum QuizStatus { idle, inProgress, finished }

/// Owns the whole quiz session.
///
/// This controller is provided above [MaterialApp], so the current question,
/// every selected answer and the running timer survive screen rotation and
/// navigation between pages.
class QuizController extends ChangeNotifier {
  QuizController({
    required List<Question> questionBank,
    Random? random,
    this.enableTicker = true,
  }) : _questionBank = List<Question>.unmodifiable(questionBank),
       _random = random ?? Random();

  final List<Question> _questionBank;
  final Random _random;

  /// Disabled by tests to avoid a pending periodic timer.
  final bool enableTicker;

  List<QuizQuestion> _questions = const <QuizQuestion>[];
  final Map<String, int> _answers = <String, int>{};
  List<ReviewEntry> _reviewEntries = const <ReviewEntry>[];

  QuizStatus _status = QuizStatus.idle;
  int _currentIndex = 0;
  String _playerName = '';
  String _lastPlayerName = '';
  QuizSettings _settings = const QuizSettings();
  QuizSettings _lastSettings = const QuizSettings();
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  QuizResult? _result;

  // ---------------------------------------------------------------------------
  // Read-only state
  // ---------------------------------------------------------------------------
  QuizStatus get status => _status;
  String get playerName => _playerName;
  String get lastPlayerName => _lastPlayerName;
  QuizSettings get settings => _settings;
  QuizSettings get lastSettings => _lastSettings;
  QuizResult? get result => _result;
  List<QuizQuestion> get questions => _questions;
  List<ReviewEntry> get reviewEntries => _reviewEntries;
  Map<String, int> get answers => Map<String, int>.unmodifiable(_answers);
  Duration get elapsed => _elapsed;
  int get currentIndex => _currentIndex;
  int get currentNumber => _questions.isEmpty ? 0 : _currentIndex + 1;
  int get totalQuestions => _questions.length;
  int get answeredCount => _answers.length;

  bool get hasActiveQuiz =>
      _status == QuizStatus.inProgress && _questions.isNotEmpty;
  bool get hasCompletedQuiz =>
      _status == QuizStatus.finished && _result != null;
  bool get isFirstQuestion => _currentIndex <= 0;
  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentIndex >= _questions.length - 1;

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty) return null;
    return _questions[_currentIndex.clamp(0, _questions.length - 1)];
  }

  int? get selectedIndex => currentQuestion == null
      ? null
      : _answers[currentQuestion!.id];

  double get positionProgress =>
      _questions.isEmpty ? 0 : (currentNumber / _questions.length).clamp(0, 1);

  double get answeredProgress =>
      _questions.isEmpty ? 0 : (answeredCount / _questions.length).clamp(0, 1);

  int? selectedIndexFor(QuizQuestion question) => _answers[question.id];

  bool isAnswered(QuizQuestion question) => _answers.containsKey(question.id);

  bool isAnsweredAt(int index) {
    if (index < 0 || index >= _questions.length) return false;
    return _answers.containsKey(_questions[index].id);
  }

  int availableCount(QuizCategory? category) {
    if (category == null) return _questionBank.length;
    return _questionBank
        .where((question) => question.category == category)
        .length;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  void startQuiz({
    required String playerName,
    required QuizSettings settings,
  }) {
    final trimmedName = playerName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(playerName, 'playerName', 'Nama wajib diisi');
    }

    final pool = settings.category == null
        ? List<Question>.of(_questionBank)
        : _questionBank
              .where((question) => question.category == settings.category)
              .toList();

    if (pool.isEmpty) {
      throw StateError('Tidak ada pertanyaan untuk kategori ini.');
    }

    if (settings.shuffleQuestions) pool.shuffle(_random);

    final count = settings.questionCount.clamp(1, pool.length);
    final selected = pool.take(count).toList();
    final prepared = <QuizQuestion>[
      for (final question in selected)
        QuizQuestion.fromSource(
          question,
          random: _random,
          shuffleOptions: settings.shuffleOptions,
        ),
    ];

    _questions = List<QuizQuestion>.unmodifiable(prepared);
    _answers.clear();
    _reviewEntries = const <ReviewEntry>[];
    _currentIndex = 0;
    _playerName = trimmedName;
    _lastPlayerName = trimmedName;
    _settings = settings.copyWith(questionCount: count);
    _lastSettings = _settings;
    _status = QuizStatus.inProgress;
    _startedAt = DateTime.now();
    _elapsed = Duration.zero;
    _result = null;
    _startTicker();
    notifyListeners();
  }

  void selectAnswer(int optionIndex) {
    final question = currentQuestion;
    if (!hasActiveQuiz || question == null) return;
    if (optionIndex < 0 || optionIndex >= question.options.length) {
      throw RangeError.range(
        optionIndex,
        0,
        question.options.length - 1,
        'optionIndex',
      );
    }
    _answers[question.id] = optionIndex;
    notifyListeners();
  }

  void clearCurrentAnswer() {
    final question = currentQuestion;
    if (!hasActiveQuiz || question == null) return;
    if (_answers.remove(question.id) != null) notifyListeners();
  }

  void goToQuestion(int index) {
    if (!hasActiveQuiz) return;
    if (index < 0 || index >= _questions.length) return;
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (!hasActiveQuiz || isLastQuestion) return;
    _currentIndex += 1;
    notifyListeners();
  }

  void previousQuestion() {
    if (!hasActiveQuiz || isFirstQuestion) return;
    _currentIndex -= 1;
    notifyListeners();
  }

  bool finishQuiz() {
    if (!hasActiveQuiz) return false;

    _stopTicker();
    if (_startedAt != null) {
      _elapsed = DateTime.now().difference(_startedAt!);
    }

    final review = <ReviewEntry>[
      for (final question in _questions)
        ReviewEntry(question: question, selectedIndex: _answers[question.id]),
    ];
    final correct = review.where((entry) => entry.isCorrect).length;
    final completedAt = DateTime.now();

    _reviewEntries = List<ReviewEntry>.unmodifiable(review);
    _result = QuizResult(
      id: '${completedAt.microsecondsSinceEpoch}-${trimmedHash(_playerName)}',
      playerName: _playerName,
      settings: _settings,
      totalQuestions: _questions.length,
      correctAnswers: correct,
      answeredQuestions: _answers.length,
      duration: _elapsed,
      completedAt: completedAt,
    );
    _status = QuizStatus.finished;
    notifyListeners();
    return true;
  }

  /// Clears the active session but keeps the last name/settings so the home
  /// form is convenient to use again.
  void resetSession() {
    _stopTicker();
    _questions = const <QuizQuestion>[];
    _answers.clear();
    _reviewEntries = const <ReviewEntry>[];
    _currentIndex = 0;
    _status = QuizStatus.idle;
    _elapsed = Duration.zero;
    _startedAt = null;
    _result = null;
    notifyListeners();
  }

  void _startTicker() {
    _stopTicker();
    if (!enableTicker) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != QuizStatus.inProgress || _startedAt == null) return;
      _elapsed = DateTime.now().difference(_startedAt!);
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String trimmedHash(String value) =>
      value.codeUnits.fold<int>(0, (a, b) => a + b).toString();

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
