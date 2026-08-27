import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences sharedPreferences;

  PreferencesService(this.sharedPreferences);

  Future<bool> setBool(String key, bool value) async {
    return sharedPreferences.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return sharedPreferences.getBool(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return sharedPreferences.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return sharedPreferences.getString(key) ?? defaultValue;
  }

  Future<bool> remove(String key) async {
    return sharedPreferences.remove(key);
  }

  Future<bool> clear() async {
    return sharedPreferences.clear();
  }
}