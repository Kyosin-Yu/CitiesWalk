import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/authentication/data/data_sources/profile_storage_data_source.dart';
import '../config/supabase_config.dart';
import '../../features/authentication/business_logic/repositories/auth_repository.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/data/data_sources/profile_data_source.dart';
import '../../features/authentication/data/data_sources/supabase_auth_data_source.dart';
import '../../features/authentication/business_logic/providers/auth_controller.dart';
import '../../features/fitness/business_logic/providers/fitness_controller.dart';
import '../../features/fitness/business_logic/repositories/fitness_repository.dart';
import '../../features/fitness/data/data_sources/fitness_local_data_source.dart';
import '../../features/fitness/data/repositories/fitness_repository_impl.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);

  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      sl<SupabaseAuthDataSource>(),
      sl<ProfileDataSource>(),
      sl<ProfileStorageDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthController>(
    () => AuthController(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<FitnessLocalDataSource>(FitnessLocalDataSource.new);

  sl.registerLazySingleton<FitnessRepository>(
    () => FitnessRepositoryImpl(sl<FitnessLocalDataSource>()),
  );

  sl.registerFactory<FitnessController>(
    () => FitnessController(sl<FitnessRepository>()),
  );

  sl.registerLazySingleton<ProfileStorageDataSource>(
        () => ProfileStorageDataSource(sl<SupabaseClient>(),),
  );
}
