import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings implements UseCase<void, SaveSettingsParams> {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSettingsParams params) async {
    return await repository.saveSettings(params.settings);
  }
}

class SaveSettingsParams extends Equatable {
  final AppSettings settings;

  const SaveSettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}
