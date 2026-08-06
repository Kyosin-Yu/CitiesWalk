import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/data/datasources/profile_datasource.dart';
import '../../features/authentication/data/datasources/supabase_auth_datasource.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<SupabaseClient>(
        () => SupabaseConfig.client,
  );

  sl.registerLazySingleton<SupabaseAuthDataSource>(
        () => SupabaseAuthDataSource(
      sl<SupabaseClient>(),
    ),
  );

  sl.registerLazySingleton<ProfileDataSource>(
        () => ProfileDataSource(
      sl<SupabaseClient>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      sl<SupabaseAuthDataSource>(),
      sl<ProfileDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthController>(
        () => AuthController(
      sl<AuthRepository>(),
    ),
  );
}