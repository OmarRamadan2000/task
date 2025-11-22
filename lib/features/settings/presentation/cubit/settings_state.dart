import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/network_device.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final List<NetworkDevice> devices;
  final bool isScanning;

  const SettingsLoaded({
    required this.settings,
    required this.devices,
    this.isScanning = false,
  });

  @override
  List<Object> get props => [settings, devices, isScanning];

  SettingsLoaded copyWith({
    AppSettings? settings,
    List<NetworkDevice>? devices,
    bool? isScanning,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}

class SettingsSaved extends SettingsState {
  final AppSettings settings;

  const SettingsSaved(this.settings);

  @override
  List<Object> get props => [settings];
}
