import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shipgo/core/localization/data/data_sources/localization_data_source.dart';
import 'package:shipgo/core/localization/data/repository/localization_repository_impl.dart';
import 'package:shipgo/core/localization/domain/repository/localization_repository.dart';
import 'package:shipgo/core/network/dio_client.dart';
import 'package:shipgo/core/security/token/data/data_sources/token_data_source.dart';
import 'package:shipgo/core/security/token/data/repository/token_repository_impl.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';
import 'package:shipgo/features/auth/data/data_sources/auth_api_service.dart';
import 'package:shipgo/features/auth/data/repository/auth_repository_impl.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';
import 'package:shipgo/features/auth/domain/usecases/check_authentication_usecase.dart';
import 'package:shipgo/features/auth/domain/usecases/sign_in_with_facebook_usecase.dart';
import 'package:shipgo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:shipgo/features/splash/data/data_sources/app_version_api_service.dart';
import 'package:shipgo/features/splash/data/repository/app_version_repository_impl.dart';
import 'package:shipgo/features/splash/domain/repository/app_version_repository.dart';
import 'package:shipgo/features/splash/domain/usecase/check_app_version_usecase.dart';
import 'package:shipgo/features/splash/presentation/bloc/check_app_version/check_app_version_bloc.dart';

final di = GetIt.instance;

Future<void> initializeDependencies() async {
  // Đăng ký dio
  di.registerLazySingleton<Dio>(
    () => createDio(localizationRepository: di<LocalizationRepository>()),
  );

  // Đăng ký các data source
  di.registerLazySingleton<TokenDataSource>(() => TokenDataSource());
  di.registerLazySingleton<LocalizationDataSource>(
    () => LocalizationDataSource(),
  );
  di.registerLazySingleton<AuthApiService>(() => AuthApiService(di<Dio>()));
  di.registerLazySingleton<AppVersionApiService>(
    () => AppVersionApiService(di<Dio>()),
  );

  // Đăng ký các repository
  di.registerLazySingleton<TokenRepository>(
    () => TokenRepositoryImpl(di<TokenDataSource>()),
  );
  di.registerLazySingleton<LocalizationRepository>(
    () => LocalizationRepositoryImpl(di<LocalizationDataSource>()),
  );
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(di<AuthApiService>()),
  );
  di.registerLazySingleton<AppVersionRepository>(
    () => AppVersionRepositoryImpl(di<AppVersionApiService>()),
  );

  // Đăng ký các usecase
  di.registerLazySingleton<SignInWithGoogleUsecase>(
    () => SignInWithGoogleUsecase(di<AuthRepository>()),
  );
  di.registerLazySingleton<SignInWithFacebookUsecase>(
    () => SignInWithFacebookUsecase(
      authRepository: di<AuthRepository>(),
      tokenRepository: di<TokenRepository>(),
    ),
  );
  di.registerLazySingleton<CheckAuthenticationUsecase>(
    () => CheckAuthenticationUsecase(di<TokenRepository>()),
  );
  di.registerLazySingleton<CheckAppVersionUsecase>(
    () => CheckAppVersionUsecase(di<AppVersionRepository>()),
  );

  // Đăng ký các bloc
  di.registerFactory<SignInBloc>(
    () => SignInBloc(
      signInWithGoogleUsecase: di<SignInWithGoogleUsecase>(),
      signInWithFacebookUsecase: di<SignInWithFacebookUsecase>(),
    ),
  );
  di.registerFactory<CheckAppVersionBloc>(
    () => CheckAppVersionBloc(di<CheckAppVersionUsecase>()),
  );
  di.registerFactory<SessionBloc>(
    () => SessionBloc(di<CheckAuthenticationUsecase>()),
  );
}
