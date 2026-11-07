import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/data/question_bank.dart';
import 'services/history_repository.dart';
import 'services/settings_store.dart';
import 'state/history_controller.dart';
import 'state/quiz_controller.dart';
import 'state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final SettingsStore settingsStore;
  late final HistoryController historyController;

  try {
    final preferences = await SharedPreferences.getInstance();
    settingsStore = SharedPreferencesSettingsStore(preferences);
    historyController = HistoryController(
      SharedPreferencesHistoryRepository(preferences),
    );
  } on Object catch (error, stackTrace) {
    // The quiz must stay usable even if platform storage is unavailable.
    debugPrint('Penyimpanan lokal tidak tersedia: $error');
    debugPrintStack(stackTrace: stackTrace);
    settingsStore = InMemorySettingsStore();
    historyController = HistoryController(InMemoryHistoryRepository());
  }

  await historyController.load();

  runApp(
    KuisCendekiaApp(
      themeController: ThemeController(settingsStore),
      historyController: historyController,
      quizController: QuizController(questionBank: QuestionBank.all),
    ),
  );
}
