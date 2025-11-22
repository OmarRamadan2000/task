import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../entities/network_device.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, void>> saveSettings(AppSettings settings);
  Future<Either<Failure, List<NetworkDevice>>> getAvailableDevices();
  Future<Either<Failure, void>> connectToDevice(String deviceId);
}
