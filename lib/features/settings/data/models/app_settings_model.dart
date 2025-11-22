import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.webUrl,
    super.selectedDeviceId,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      webUrl: json['webUrl'] ?? 'https://www.google.com',
      selectedDeviceId: json['selectedDeviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'webUrl': webUrl,
      'selectedDeviceId': selectedDeviceId,
    };
  }
}
