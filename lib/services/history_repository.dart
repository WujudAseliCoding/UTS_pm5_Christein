import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/question.dart';

/// Persistence boundary for quiz history. The app only needs this simple
/// key-value repository, not a database.
abstract interface class HistoryRepository {
  Future<List<QuizResult>> load();
  Future<void> save(List<QuizResult> results);
}

class SharedPreferencesHistoryRepository implements HistoryRepository {
  const SharedPreferencesHistoryRepository(this._preferences);

  static const String storageKey = 'kuis_cendekia.history_v1';

  final SharedPreferences _preferences;

  @override
  Future<List<QuizResult>> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return <QuizResult>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <QuizResult>[];
      final results = <QuizResult>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          results.add(
            QuizResult.fromJson(Map<String, dynamic>.from(item)),
          );
        } on Object {
          // A single damaged entry must not wipe the whole history.
        }
      }
      return results;
    } on FormatException {
      return <QuizResult>[];
    }
  }

  @override
  Future<void> save(List<QuizResult> results) async {
    final payload = jsonEncode(
      <Map<String, dynamic>>[for (final result in results) result.toJson()],
    );
    await _preferences.setString(storageKey, payload);
  }
}

/// Test double and safe fallback when persistence is unavailable.
class InMemoryHistoryRepository implements HistoryRepository {
  InMemoryHistoryRepository([List<QuizResult>? initialResults])
    : _results = <QuizResult>[...?initialResults];

  List<QuizResult> _results;

  @override
  Future<List<QuizResult>> load() async => List<QuizResult>.of(_results);

  @override
  Future<void> save(List<QuizResult> results) async {
    _results = List<QuizResult>.of(results);
  }
}
