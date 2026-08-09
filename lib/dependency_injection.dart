import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shipgo/core/network/dio_client.dart';
import 'package:shipgo/core/storage/token_storage.dart';
import 'package:shipgo/features/auth/data/data_sources/remote/auth_api_service.dart';
import 'package:shipgo/features/auth/data/repository/auth_repository_impl.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';
import 'package:shipgo/features/auth/domain/usecases/sign_in_with_facebook_usecase.dart';
import 'package:shipgo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';

final di = GetIt.instance;

Future<void> initializeDependencies() async {
  // Đăng ký các đối tượng secure storage
  di.registerLazySingleton<TokenStorage>(
    () => TokenStorage(FlutterSecureStorage()),
  );

  // Đăng ký dio
  di.registerLazySingleton<Dio>(() => createDio());

  // Đăng ký các data source
  di.registerLazySingleton<AuthAPIService>(() => AuthAPIService(di<Dio>()));

  // Đăng ký các repository
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(di<AuthAPIService>(), di<TokenStorage>()),
  );

  // Đăng ký các usecase
  di.registerLazySingleton<SignInWithGoogleUsecase>(
    () => SignInWithGoogleUsecase(di<AuthRepository>()),
  );
  di.registerLazySingleton<SignInWithFacebookUsecase>(
    () => SignInWithFacebookUsecase(di<AuthRepository>()),
  );

  // Đăng ký các bloc
  di.registerLazySingleton<SignInBloc>(
    () => SignInBloc(
      signInWithGoogleUsecase: di<SignInWithGoogleUsecase>(),
      signInWithFacebookUsecase: di<SignInWithFacebookUsecase>(),
    ),
  );
}
