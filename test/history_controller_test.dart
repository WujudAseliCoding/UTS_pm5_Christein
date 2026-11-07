import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm5_christein/data/models/question.dart';
import 'package:uts_pm5_christein/data/models/quiz_settings.dart';
import 'package:uts_pm5_christein/services/history_repository.dart';
import 'package:uts_pm5_christein/state/history_controller.dart';

QuizResult makeResult({
  required String id,
  required int correct,
  required String name,
  required DateTime date,
  int total = 10,
}) {
  return QuizResult(
    id: id,
    playerName: name,
    settings: const QuizSettings(category: QuizCategory.flutter),
    totalQuestions: total,
    correctAnswers: correct,
    answeredQuestions: total,
    duration: const Duration(minutes: 2, seconds: 30),
    completedAt: date,
  );
}

void main() {
  test('loads, sorts and identifies the best score', () async {
    final repository = InMemoryHistoryRepository(<QuizResult>[
      makeResult(
        id: 'old',
        correct: 6,
        name: 'Rani',
        date: DateTime(2026, 10, 1),
      ),
      makeResult(
        id: 'best',
        correct: 9,
        name: 'Bima',
        date: DateTime(2026, 10, 2),
      ),
      makeResult(
        id: 'newest',
        correct: 7,
        name: 'Sari',
        date: DateTime(2026, 10, 3),
      ),
    ]);
    final controller = HistoryController(repository);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.isLoaded, isTrue);
    expect(controller.items.map((item) => item.id), <String>[
      'newest',
      'best',
      'old',
    ]);
    expect(controller.bestScore, 90);
    expect(controller.bestResult?.playerName, 'Bima');
  });

  test('records new results once and persists them', () async {
    final repository = InMemoryHistoryRepository();
    final controller = HistoryController(repository);
    addTearDown(controller.dispose);
    await controller.load();

    final previous = makeResult(
      id: 'first',
      correct: 6,
      name: 'Rani',
      date: DateTime(2026, 10, 1),
    );
    final better = makeResult(
      id: 'second',
      correct: 9,
      name: 'Rani',
      date: DateTime(2026, 10, 2),
    );

    await controller.record(previous);
    expect(controller.items, hasLength(1));
    expect(controller.isNewRecord(previous), isFalse);
    expect(controller.hasPreviousAttempts(previous), isFalse);

    await controller.record(better);
    expect(controller.items, hasLength(2));
    expect(controller.bestScore, 90);
    expect(controller.isNewRecord(better), isTrue);
    expect(controller.hasPreviousAttempts(better), isTrue);

    // Duplicate ids must not create duplicate entries.
    await controller.record(better);
    expect(controller.items, hasLength(2));

    final reloaded = HistoryController(repository);
    addTearDown(reloaded.dispose);
    await reloaded.load();
    expect(reloaded.items, hasLength(2));
    expect(reloaded.bestScore, 90);
  });

  test('does not call a tied score a new record', () async {
    final controller = HistoryController(InMemoryHistoryRepository());
    addTearDown(controller.dispose);
    await controller.load();

    await controller.record(
      makeResult(
        id: 'a',
        correct: 8,
        name: 'Rani',
        date: DateTime(2026, 10, 1),
      ),
    );
    final tied = makeResult(
      id: 'b',
      correct: 8,
      name: 'Rani',
      date: DateTime(2026, 10, 2),
    );
    expect(controller.isNewRecord(tied), isFalse);
  });

  test('keeps only the latest 20 entries', () async {
    final controller = HistoryController(InMemoryHistoryRepository());
    addTearDown(controller.dispose);
    await controller.load();

    for (var index = 0; index < 25; index++) {
      await controller.record(
        makeResult(
          id: 'result-$index',
          correct: index % 11,
          name: 'Pemain $index',
          date: DateTime(2026, 10, 1).add(Duration(minutes: index)),
        ),
      );
    }

    expect(controller.items, hasLength(HistoryController.maxEntries));
    expect(controller.items.first.id, 'result-24');
    expect(controller.items.last.id, 'result-5');
  });

  test('clears history and the repository', () async {
    final repository = InMemoryHistoryRepository(<QuizResult>[
      makeResult(
        id: 'old',
        correct: 5,
        name: 'Rani',
        date: DateTime(2026, 10, 1),
      ),
    ]);
    final controller = HistoryController(repository);
    addTearDown(controller.dispose);
    await controller.load();

    await controller.clear();

    expect(controller.items, isEmpty);
    expect(await repository.load(), isEmpty);
  });
}
