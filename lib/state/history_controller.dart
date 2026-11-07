import 'package:flutter/foundation.dart';

import '../data/models/question.dart';
import '../services/history_repository.dart';

/// In-memory view of the locally persisted score history.
class HistoryController extends ChangeNotifier {
  HistoryController(this._repository);

  static const int maxEntries = 20;

  final HistoryRepository _repository;
  List<QuizResult> _items = const <QuizResult>[];
  bool _isLoaded = false;
  bool _isSaving = false;
  Object? _lastError;

  List<QuizResult> get items => List<QuizResult>.unmodifiable(_items);
  bool get isLoaded => _isLoaded;
  bool get isSaving => _isSaving;
  bool get isEmpty => _items.isEmpty;
  Object? get lastError => _lastError;

  QuizResult? get bestResult {
    if (_items.isEmpty) return null;
    return _items.reduce((current, next) {
      if (next.score > current.score) return next;
      if (next.score == current.score &&
          next.completedAt.isAfter(current.completedAt)) {
        return next;
      }
      return current;
    });
  }

  int get bestScore => bestResult?.score ?? 0;

  Future<void> load() async {
    try {
      final loaded = await _repository.load();
      loaded.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      _items = List<QuizResult>.unmodifiable(loaded.take(maxEntries));
      _lastError = null;
    } on Object catch (error) {
      _lastError = error;
      _items = const <QuizResult>[];
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> record(QuizResult result) async {
    if (_items.any((item) => item.id == result.id)) return;

    _items = List<QuizResult>.unmodifiable(
      <QuizResult>[result, ..._items].take(maxEntries),
    );
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.save(_items);
      _lastError = null;
    } on Object catch (error) {
      _lastError = error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _items = const <QuizResult>[];
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.save(const <QuizResult>[]);
      _lastError = null;
    } on Object catch (error) {
      _lastError = error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// A new record must strictly beat a previous attempt. The first attempt is
  /// not labelled as a record because there is nothing to beat yet.
  bool isNewRecord(QuizResult result) {
    final previous = _items.where((item) => item.id != result.id).toList();
    if (previous.isEmpty) return false;
    final previousBest = previous
        .map((item) => item.score)
        .reduce((a, b) => a > b ? a : b);
    return result.score > previousBest;
  }

  bool hasPreviousAttempts(QuizResult result) =>
      _items.any((item) => item.id != result.id);
}
