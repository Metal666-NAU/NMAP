import 'package:shared_preferences/shared_preferences.dart';

enum Settings<T extends Object?> {
  lastPlayedFile<String?>("last_played_file");

  static late SharedPreferences _sharedPreferences;

  final String _key;

  const Settings(this._key);

  T get value => _sharedPreferences.get(_key) as T;

  Future save(T value) async {
    if (value == null) {
      await _sharedPreferences.remove(_key);
    } else {
      if (value is String?) {
        await _sharedPreferences.setString(_key, value as String);
      }
    }
  }

  static Future init() async =>
      _sharedPreferences = await SharedPreferences.getInstance();
}
