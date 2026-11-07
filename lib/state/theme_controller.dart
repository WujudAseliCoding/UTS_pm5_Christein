import 'dart:async';

import 'package:flutter/material.dart';

import '../services/settings_store.dart';

/// Persists the user's theme choice (bonus: dual theme).
class ThemeController extends ChangeNotifier {
  ThemeController(
    this._store, {
    ThemeMode fallback = ThemeMode.system,
  }) {
    _mode = _readMode() ?? fallback;
  }

  static const String storageKey = 'kuis_cendekia.theme_mode';

  final SettingsStore _store;
  late ThemeMode _mode;

  ThemeMode get mode => _mode;

  String get label => switch (_mode) {
    ThemeMode.system => 'Ikuti sistem',
    ThemeMode.light => 'Mode terang',
    ThemeMode.dark => 'Mode gelap',
  };

  ThemeMode? _readMode() {
    final value = _store.read(storageKey);
    if (value == null) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    unawaited(_store.write(storageKey, mode.name));
  }

  /// Flips between light and dark based on the currently rendered brightness.
  void toggle(Brightness currentBrightness) {
    setMode(
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
