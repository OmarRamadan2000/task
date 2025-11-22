import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/device_data_source.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final DeviceDataSource deviceDataSource;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.deviceDataSource,
  });

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      final settingsModel = AppSettingsModel(
        webUrl: settings.webUrl,
        selectedDeviceId: settings.selectedDeviceId,
      );
      await localDataSource.saveSettings(settingsModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<NetworkDevice>>> getAvailableDevices() async {
    try {
      final devices = await deviceDataSource.scanDevices();
      return Right(devices);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(PermissionFailure('Failed to scan devices'));
    }
  }

  @override
  Future<Either<Failure, void>> connectToDevice(String deviceId) async {
    try {
      await deviceDataSource.connectToDevice(deviceId);
      return const Right(null);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(PermissionFailure('Failed to connect to device'));
    }
  }
}
