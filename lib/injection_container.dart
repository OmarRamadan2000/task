import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;

// Core
import 'core/network/network_info.dart';
import 'core/services/app_update_service.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Settings
import 'features/settings/data/datasources/device_data_source.dart';
import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_available_devices.dart';
import 'features/settings/domain/usecases/get_settings.dart';
import 'features/settings/domain/usecases/save_settings.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      signInWithGoogle: sl(),
      signInWithFacebook: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithFacebook(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      facebookAuth: sl(),
    ),
  );

  //! Features - Settings
  // Cubit
  sl.registerFactory(
    () => SettingsCubit(
      getSettings: sl(),
      saveSettings: sl(),
      getAvailableDevices: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => SaveSettings(sl()));
  sl.registerLazySingleton(() => GetAvailableDevices(sl()));

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl(), deviceDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<DeviceDataSource>(
    () => DeviceDataSourceImpl(networkInfo: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final updateService = AppUpdateService();
  await updateService.init();
  sl.registerLazySingleton(() => updateService);

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FacebookAuth.instance);
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton(() => network_info_plus.NetworkInfo());
}
