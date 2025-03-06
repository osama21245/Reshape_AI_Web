import 'package:get_it/get_it.dart';
import 'package:reshapeai/data/datasources/auth_data_source.dart';
import 'package:reshapeai/data/datasources/transformation_data_source.dart';
import 'package:reshapeai/data/datasources/user_data_source.dart';
import 'package:reshapeai/data/repositories/auth_repository_impl.dart';
import 'package:reshapeai/data/repositories/transformation_repository_impl.dart';
import 'package:reshapeai/data/repositories/user_repository_impl.dart';
import 'package:reshapeai/domain/repositories/auth_repository.dart';
import 'package:reshapeai/domain/repositories/transformation_repository.dart';
import 'package:reshapeai/domain/repositories/user_repository.dart';
import 'package:reshapeai/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/get_token_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/logout_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/scan_qr_usecase.dart';
import 'package:reshapeai/domain/usecases/transformation/create_transformation_usecase.dart';
import 'package:reshapeai/domain/usecases/transformation/get_transformations_usecase.dart';
import 'package:reshapeai/domain/usecases/user/get_user_details_usecase.dart';
import 'package:reshapeai/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_cubit.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://reshape-ai-web.vercel.app',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(dio: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<UserDataSource>(
    () => UserDataSourceImpl(dio: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<TransformationDataSource>(
    () => TransformationDataSourceImpl(dio: sl(), secureStorage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<TransformationRepository>(
    () => TransformationRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  // Auth use cases
  sl.registerLazySingleton(() => ScanQrUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(repository: sl()));

  // User use cases
  sl.registerLazySingleton(() => GetUserDetailsUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(repository: sl()));

  // Transformation use cases
  sl.registerLazySingleton(() => GetTransformationsUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateTransformationUseCase(repository: sl()));

  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      scanQrUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      getTokenUseCase: sl(),
    ),
  );
  sl.registerFactory(() => UserCubit(
        getUserDetailsUseCase: sl(),
        updateUserProfileUseCase: sl(),
      ));
  sl.registerFactory(
    () => TransformationCubit(
      getTransformationsUseCase: sl(),
      createTransformationUseCase: sl(),
    ),
  );
}
