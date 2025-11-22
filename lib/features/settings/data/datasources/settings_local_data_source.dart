import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String settingsKey = 'APP_SETTINGS';

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final jsonString = sharedPreferences.getString(settingsKey);
      if (jsonString != null) {
        return AppSettingsModel.fromJson(json.decode(jsonString));
      }
      // Return default settings
      return const AppSettingsModel(webUrl: 'https://www.google.com');
    } catch (e) {
      throw CacheException('Failed to get settings');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      await sharedPreferences.setString(settingsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save settings');
    }
  }
}
