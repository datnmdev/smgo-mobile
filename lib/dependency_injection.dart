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
import 'package:shipgo/features/location/data/data_sources/location_api_service.dart';
import 'package:shipgo/features/location/data/data_sources/storage_api_service.dart';
import 'package:shipgo/features/location/data/repository/location_repository_impl.dart';
import 'package:shipgo/features/location/data/repository/storage_repository_impl.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';
import 'package:shipgo/features/location/domain/repository/storage_repository.dart';
import 'package:shipgo/features/location/domain/usecases/add_location_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/delete_location_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/upload_media_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/add_location_form/add_location_form_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/delete_location/delete_location_cubic.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/location_selection/location_selection_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/search_locations/search_locations_cubit.dart';
import 'package:shipgo/features/splash/data/data_sources/app_version_api_service.dart';
import 'package:shipgo/features/splash/data/repository/app_version_repository_impl.dart';
import 'package:shipgo/features/splash/domain/repository/app_version_repository.dart';
import 'package:shipgo/features/splash/domain/usecase/check_app_version_usecase.dart';
import 'package:shipgo/features/splash/presentation/bloc/check_app_version/check_app_version_bloc.dart';

final di = GetIt.instance;

Future<void> initializeDependencies() async {
  // Đăng ký dio
  di.registerLazySingleton<Dio>(
    () => createDio(
      localizationRepository: di<LocalizationRepository>(),
      tokenRepository: di<TokenRepository>(),
    ),
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
  di.registerLazySingleton<LocationApiService>(
    () => LocationApiService(di<Dio>()),
  );
  di.registerLazySingleton<StorageApiService>(
    () => StorageApiService(di<Dio>()),
  );

  // Đăng ký các repository
  di.registerLazySingleton<TokenRepository>(
    () => TokenRepositoryImpl(di<TokenDataSource>()),
  );
  di.registerLazySingleton<LocalizationRepository>(
    () => LocalizationRepositoryImpl(di<LocalizationDataSource>()),
  );
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authApiService: di<AuthApiService>()),
  );
  di.registerLazySingleton<AppVersionRepository>(
    () => AppVersionRepositoryImpl(
      appVersionApiService: di<AppVersionApiService>(),
    ),
  );
  di.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(locationApiService: di<LocationApiService>()),
  );
  di.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(storageApiService: di<StorageApiService>()),
  );

  // Đăng ký các usecase
  di.registerLazySingleton<SignInWithGoogleUsecase>(
    () => SignInWithGoogleUsecase(
      authRepository: di<AuthRepository>(),
      tokenRepository: di<TokenRepository>(),
    ),
  );
  di.registerLazySingleton<SignInWithFacebookUsecase>(
    () => SignInWithFacebookUsecase(
      authRepository: di<AuthRepository>(),
      tokenRepository: di<TokenRepository>(),
    ),
  );
  di.registerLazySingleton<CheckAuthenticationUsecase>(
    () => CheckAuthenticationUsecase(tokenRepository: di<TokenRepository>()),
  );
  di.registerLazySingleton<CheckAppVersionUsecase>(
    () => CheckAppVersionUsecase(
      appVersionRepository: di<AppVersionRepository>(),
    ),
  );
  di.registerLazySingleton<GetMyLocationsUsecase>(
    () => GetMyLocationsUsecase(locationRepository: di<LocationRepository>()),
  );
  di.registerLazySingleton<GetUploadUrlUsecase>(
    () => GetUploadUrlUsecase(storageRepository: di<StorageRepository>()),
  );
  di.registerLazySingleton<GetDownloadUrlUsecase>(
    () => GetDownloadUrlUsecase(storageRepository: di<StorageRepository>()),
  );
  di.registerLazySingleton<UploadMediaUsecase>(() => UploadMediaUsecase());
  di.registerLazySingleton<AddLocationUsecase>(
    () => AddLocationUsecase(locationRepository: di<LocationRepository>()),
  );
  di.registerLazySingleton<DeleteLocationUsecase>(
    () => DeleteLocationUsecase(locationRepository: di<LocationRepository>()),
  );

  // Đăng ký các bloc
  di.registerFactory<SignInBloc>(
    () => SignInBloc(
      signInWithGoogleUsecase: di<SignInWithGoogleUsecase>(),
      signInWithFacebookUsecase: di<SignInWithFacebookUsecase>(),
    ),
  );
  di.registerFactory<CheckAppVersionBloc>(
    () => CheckAppVersionBloc(
      checkAppVersionUsecase: di<CheckAppVersionUsecase>(),
    ),
  );
  di.registerFactory<SessionBloc>(
    () => SessionBloc(
      checkAuthenticationUsecase: di<CheckAuthenticationUsecase>(),
    ),
  );
  di.registerFactory<GetMyLocationsCubit>(
    () =>
        GetMyLocationsCubit(getMyLocationsUsecase: di<GetMyLocationsUsecase>()),
  );
  di.registerFactory<AddLocationFormCubit>(
    () => AddLocationFormCubit(addLocationUsecase: di<AddLocationUsecase>()),
  );
  di.registerFactory<LocationSelectionCubit>(() => LocationSelectionCubit());
  di.registerFactory<DeleteLocationCubic>(
    () =>
        DeleteLocationCubic(deleteLocationUsecase: di<DeleteLocationUsecase>()),
  );
  di.registerFactory<SearchLocationsCubit>(() => SearchLocationsCubit());
}
