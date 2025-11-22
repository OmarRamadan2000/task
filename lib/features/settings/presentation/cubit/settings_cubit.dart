import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_available_devices.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettings getSettings;
  final SaveSettings saveSettings;
  final GetAvailableDevices getAvailableDevices;

  SettingsCubit({
    required this.getSettings,
    required this.saveSettings,
    required this.getAvailableDevices,
  }) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings, devices: const [])),
    );
  }

  Future<void> scanDevices() async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(isScanning: true));

      final result = await getAvailableDevices(NoParams());
      result.fold(
        (failure) {
          emit(currentState.copyWith(isScanning: false));
          emit(SettingsError(failure.message));
        },
        (devices) {
          emit(currentState.copyWith(devices: devices, isScanning: false));
        },
      );
    }
  }

  Future<void> updateWebUrl(String url) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updatedSettings = currentState.settings.copyWith(webUrl: url);
      final result = await saveSettings(
        SaveSettingsParams(settings: updatedSettings),
      );

      result.fold((failure) => emit(SettingsError(failure.message)), (_) {
        emit(currentState.copyWith(settings: updatedSettings));
        emit(SettingsSaved(updatedSettings));
      });
    }
  }

  Future<void> selectDevice(String? deviceId) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updatedSettings = currentState.settings.copyWith(
        selectedDeviceId: deviceId,
      );
      final result = await saveSettings(
        SaveSettingsParams(settings: updatedSettings),
      );

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(settings: updatedSettings)),
      );
    }
  }
}
