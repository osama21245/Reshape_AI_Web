import 'package:get_it/get_it.dart';
import 'package:reshapeai/data/datasources/auth_data_source.dart';
import 'package:reshapeai/data/datasources/transformation_data_source.dart';
import 'package:reshapeai/data/datasources/user_data_source.dart';
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

  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      authDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => UserCubit(
      userDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => TransformationCubit(
      transformationDataSource: sl(),
    ),
  );
}
