import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../services/eco_points_service.dart';
import '../../features/authentication/business_logic/repositories/auth_repository.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/data/data_sources/profile_data_source.dart';
import '../../features/authentication/data/data_sources/supabase_auth_data_source.dart';
import '../../features/authentication/business_logic/providers/auth_controller.dart';
import '../../features/fitness/business_logic/repositories/fitness_repository.dart';
import '../../features/fitness/data/data_sources/supabase_fitness_data_source.dart';
import '../../features/fitness/data/repositories/fitness_repository_impl.dart';
import '../../features/rewards/business_logic/repositories/rewards_repository.dart';
import '../../features/rewards/data/data_sources/rewards_data_source.dart';
import '../../features/rewards/data/data_sources/supabase_rewards_data_source.dart';
import '../../features/rewards/data/repositories/rewards_repository_impl.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);
  sl.registerLazySingleton<EcoPointsService>(
    () => EcoPointsService(sl<SupabaseClient>()),
  );

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
    ),
  );

  sl.registerLazySingleton<AuthController>(
    () => AuthController(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SupabaseFitnessDataSource>(
    () => SupabaseFitnessDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<FitnessRepository>(
    () => FitnessRepositoryImpl(sl<SupabaseFitnessDataSource>()),
  );

  sl.registerLazySingleton<RewardsDataSource>(
    () => SupabaseRewardsDataSource(
      sl<SupabaseClient>(),
      sl<EcoPointsService>(),
    ),
  );
  sl.registerLazySingleton<RewardsRepository>(
    () => RewardsRepositoryImpl(sl<RewardsDataSource>()),
  );
}
