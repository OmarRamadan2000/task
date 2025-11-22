import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String webUrl;
  final String? selectedDeviceId;

  const AppSettings({
    required this.webUrl,
    this.selectedDeviceId,
  });

  @override
  List<Object?> get props => [webUrl, selectedDeviceId];

  AppSettings copyWith({
    String? webUrl,
    String? selectedDeviceId,
  }) {
    return AppSettings(
      webUrl: webUrl ?? this.webUrl,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
    );
  }
}
