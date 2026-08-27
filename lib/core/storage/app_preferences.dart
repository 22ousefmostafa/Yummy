import 'preferences_service.dart';
import 'storage_keys.dart';

class AppPreferences {
  final PreferencesService preferencesService;

  AppPreferences(this.preferencesService);

  Future<bool> setHasSeenOnboarding(bool value) async {
    return preferencesService.setBool(StorageKeys.hasSeenOnboarding, value);
  }

  bool getHasSeenOnboarding() {
    return preferencesService.getBool(
      StorageKeys.hasSeenOnboarding,
      defaultValue: false,
    );
  }

  Future<bool> setThemeMode(String value) async {
    return preferencesService.setString(StorageKeys.themeMode, value);
  }

  String getThemeMode() {
    return preferencesService.getString(
      StorageKeys.themeMode,
      defaultValue: 'light',
    );
  }
}