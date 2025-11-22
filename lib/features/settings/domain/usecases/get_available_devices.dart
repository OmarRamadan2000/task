import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/network_device.dart';
import '../repositories/settings_repository.dart';

class GetAvailableDevices implements UseCase<List<NetworkDevice>, NoParams> {
  final SettingsRepository repository;

  GetAvailableDevices(this.repository);

  @override
  Future<Either<Failure, List<NetworkDevice>>> call(NoParams params) async {
    return await repository.getAvailableDevices();
  }
}
