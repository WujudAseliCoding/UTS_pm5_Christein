import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value abstraction so controllers are easy to test without the
/// platform plugin.
abstract interface class SettingsStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  const SharedPreferencesSettingsStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([Map<String, String>? initialValues])
    : _values = <String, String>{...?initialValues};

  final Map<String, String> _values;

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
