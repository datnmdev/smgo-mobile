import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smgo/core/localization/data/data_sources/localization_data_source.dart';
import 'package:smgo/core/localization/data/repository/localization_repository_impl.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/localization/domain/usecases/get_locale_usecase.dart';
import 'package:smgo/core/localization/domain/usecases/set_locale_usecase.dart';
import 'package:smgo/core/localization/presentation/bloc/get_locale/get_locale_cubit.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_cubit.dart';
import 'package:smgo/core/network/dio_client.dart';
import 'package:smgo/core/security/token/data/data_sources/token_data_source.dart';
import 'package:smgo/core/security/token/data/repository/token_repository_impl.dart';
import 'package:smgo/core/security/token/domain/repository/token_repository.dart';
import 'package:smgo/core/security/token/domain/usecases/clear_token_usecase.dart';
import 'package:smgo/features/auth/data/data_sources/auth_api_service.dart';
import 'package:smgo/features/auth/data/repository/auth_repository_impl.dart';
import 'package:smgo/features/auth/domain/repository/auth_repository.dart';
import 'package:smgo/features/auth/domain/usecases/check_authentication_usecase.dart';
import 'package:smgo/features/auth/domain/usecases/sign_in_with_facebook_usecase.dart';
import 'package:smgo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smgo/features/delivery_route/data/data_sources/share_location_api_service.dart';
import 'package:smgo/features/delivery_route/data/repository/share_location_repository_impl.dart';
import 'package:smgo/features/delivery_route/domain/repository/share_location_repository.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_share_location_url_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_share_location_url/get_share_location_url_cubit.dart';
import 'package:smgo/features/splash/presentation/bloc/check_session/check_session_cubit.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:smgo/features/delivery_route/data/data_sources/ai_api_service.dart';
import 'package:smgo/features/delivery_route/data/data_sources/location_search_api_service.dart';
import 'package:smgo/features/delivery_route/data/repository/ai_repository_impl.dart';
import 'package:smgo/features/delivery_route/data/repository/location_search_repository_impl.dart';
import 'package:smgo/features/delivery_route/domain/repository/ai_repository.dart';
import 'package:smgo/features/delivery_route/domain/repository/location_search_repository.dart';
import 'package:smgo/features/delivery_route/domain/usecases/Confirm_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/add_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/confirm_sorted_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/create_delivery_route_with_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/delete_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/extract_order_info_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_location_suggestions_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/recheck_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/sort_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_cancelled_order/confirm_cancelled_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivered_order/confirm_delivered_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_rescheduled_order/confirm_rescheduled_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_sorted_delivery_orders/confirm_sorted_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/create_delivery_route_with_orders/create_delivery_route_with_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_cubit.dart';
import 'package:smgo/shared/data/data_sources/session_api_service.dart';
import 'package:smgo/shared/data/data_sources/subscription_api_service.dart';
import 'package:smgo/shared/data/repository/session_repository_impl.dart';
import 'package:smgo/shared/data/repository/subscription_repository_impl.dart';
import 'package:smgo/shared/domain/repository/session_repository.dart';
import 'package:smgo/shared/domain/repository/subscription_repository.dart';
import 'package:smgo/shared/domain/usecases/get_current_subscription_usecase.dart';
import 'package:smgo/shared/domain/usecases/signout_usecase.dart';
import 'package:smgo/shared/domain/usecases/update_profile_usecase.dart';
import 'package:smgo/shared/domain/usecases/verify_subscription_usecase.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_orders/search_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_completed/transition_route_to_completed_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_delivering/transition_route_to_delivering_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/update_delivery_order_form/update_delivery_order_form_cubit.dart';
import 'package:smgo/features/location/data/data_sources/location_api_service.dart';
import 'package:smgo/shared/data/data_sources/storage_api_service.dart';
import 'package:smgo/features/location/data/repository/location_repository_impl.dart';
import 'package:smgo/shared/data/repository/storage_repository_impl.dart';
import 'package:smgo/features/location/domain/repository/location_repository.dart';
import 'package:smgo/shared/domain/repository/storage_repository.dart';
import 'package:smgo/features/location/domain/usecases/add_location_usecase.dart';
import 'package:smgo/features/location/domain/usecases/delete_locations_usecase.dart';
import 'package:smgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:smgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:smgo/features/location/domain/usecases/update_location_usecase.dart';
import 'package:smgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/add_location_form/add_location_form_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/search_locations/search_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/update_location_form/update_location_form_cubit.dart';
import 'package:smgo/features/delivery_route/data/data_sources/delivery_route_api_service.dart';
import 'package:smgo/features/delivery_route/data/repository/delivery_route_repository_impl.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';
import 'package:smgo/features/delivery_route/domain/usecases/add_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/delete_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_route_form/add_delivery_route_form_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_routes/search_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/update_delivery_route_form/update_delivery_route_form_cubit.dart';
import 'package:smgo/features/splash/data/data_sources/app_version_api_service.dart';
import 'package:smgo/features/splash/data/repository/app_version_repository_impl.dart';
import 'package:smgo/features/splash/domain/repository/app_version_repository.dart';
import 'package:smgo/features/splash/domain/usecase/check_app_version_usecase.dart';
import 'package:smgo/features/splash/presentation/bloc/check_app_version/check_app_version_bloc.dart';
import 'package:smgo/shared/data/data_sources/user_api_service.dart';
import 'package:smgo/shared/data/repository/user_repository_impl.dart';
import 'package:smgo/shared/domain/repository/user_repository.dart';
import 'package:smgo/shared/domain/usecases/get_profile_usecase.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_cubit.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_cubit.dart';
import 'package:smgo/shared/presentation/bloc/subscription_purchase/subscription_purchase_cubit.dart';
import 'package:smgo/features/person/presentation/bloc/update_profile_form/update_profile_form_cubit.dart';

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
  di.registerLazySingleton<DeliveryRouteApiService>(
    () => DeliveryRouteApiService(di<Dio>()),
  );
  di.registerLazySingleton<AiApiService>(() => AiApiService(di<Dio>()));
  di.registerLazySingleton<LocationSearchApiService>(
    () => LocationSearchApiService(di<Dio>()),
  );
  di.registerLazySingleton<UserApiService>(() => UserApiService(di<Dio>()));
  di.registerLazySingleton<SessionApiService>(
    () => SessionApiService(di<Dio>()),
  );
  di.registerLazySingleton<SubscriptionApiService>(
    () => SubscriptionApiService(di<Dio>()),
  );
  di.registerLazySingleton<ShareLocationApiService>(
    () => ShareLocationApiService(di<Dio>()),
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
  di.registerLazySingleton<DeliveryRouteRepository>(
    () => DeliveryRouteRepositoryImpl(
      deliveryRouteApiService: di<DeliveryRouteApiService>(),
    ),
  );
  di.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(aiApiService: di<AiApiService>()),
  );
  di.registerLazySingleton<LocationSearchRepository>(
    () => LocationSearchRepositoryImpl(
      locationSearchApiService: di<LocationSearchApiService>(),
    ),
  );
  di.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userApiService: di<UserApiService>()),
  );
  di.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sessionApiService: di<SessionApiService>()),
  );
  di.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      subscriptionApiService: di<SubscriptionApiService>(),
    ),
  );
  di.registerLazySingleton<ShareLocationRepository>(
    () => ShareLocationRepositoryImpl(
      shareLocationApiService: di<ShareLocationApiService>(),
    ),
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
  di.registerLazySingleton<UploadMediaUsecase>(
    () => UploadMediaUsecase(storageRepository: di<StorageRepository>()),
  );
  di.registerLazySingleton<AddLocationUsecase>(
    () => AddLocationUsecase(locationRepository: di<LocationRepository>()),
  );
  di.registerLazySingleton<DeleteLocationsUsecase>(
    () => DeleteLocationsUsecase(locationRepository: di<LocationRepository>()),
  );
  di.registerLazySingleton<UpdateLocationUsecase>(
    () => UpdateLocationUsecase(locationRepository: di<LocationRepository>()),
  );
  di.registerLazySingleton<AddDeliveryRouteUsecase>(
    () => AddDeliveryRouteUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<GetDeliveryRoutesUsecase>(
    () => GetDeliveryRoutesUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<UpdateDeliveryRouteUsecase>(
    () => UpdateDeliveryRouteUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<DeleteDeliveryRoutesUsecase>(
    () => DeleteDeliveryRoutesUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<AddDeliveryOrderUsecase>(
    () => AddDeliveryOrderUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<ExtractOrderInfoUsecase>(
    () => ExtractOrderInfoUsecase(aiRepository: di<AiRepository>()),
  );
  di.registerLazySingleton<GetLocationSuggestionsUsecase>(
    () => GetLocationSuggestionsUsecase(
      locationSearchRepository: di<LocationSearchRepository>(),
    ),
  );
  di.registerLazySingleton<UpdateDeliveryOrderUsecase>(
    () => UpdateDeliveryOrderUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<DeleteDeliveryOrdersUsecase>(
    () => DeleteDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<GetProfileUsecase>(
    () => GetProfileUsecase(userRepository: di<UserRepository>()),
  );
  di.registerLazySingleton<RecheckDeliveryOrdersUsecase>(
    () => RecheckDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<ConfirmDeliveryOrdersUsecase>(
    () => ConfirmDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<SortDeliveryOrdersUsecase>(
    () => SortDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<ConfirmSortedDeliveryOrdersUsecase>(
    () => ConfirmSortedDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<CreateDeliveryRouteWithOrdersUsecase>(
    () => CreateDeliveryRouteWithOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<GetDeliveryOrdersUsecase>(
    () => GetDeliveryOrdersUsecase(
      deliveryRouteRepository: di<DeliveryRouteRepository>(),
    ),
  );
  di.registerLazySingleton<SignoutUsecase>(
    () => SignoutUsecase(sessionRepository: di<SessionRepository>()),
  );
  di.registerLazySingleton<ClearTokenUsecase>(
    () => ClearTokenUsecase(tokenRepository: di<TokenRepository>()),
  );
  di.registerLazySingleton<VerifySubscriptionUsecase>(
    () => VerifySubscriptionUsecase(
      subscriptionRepository: di<SubscriptionRepository>(),
    ),
  );
  di.registerLazySingleton<GetCurrentSubscriptionUsecase>(
    () => GetCurrentSubscriptionUsecase(
      subscriptionRepository: di<SubscriptionRepository>(),
    ),
  );
  di.registerLazySingleton<UpdateProfileUsecase>(
    () => UpdateProfileUsecase(userRepository: di<UserRepository>()),
  );
  di.registerLazySingleton<GetShareLocationUrlUsecase>(
    () => GetShareLocationUrlUsecase(
      shareLocationRepository: di<ShareLocationRepository>(),
    ),
  );
  di.registerLazySingleton<GetLocaleUsecase>(
    () =>
        GetLocaleUsecase(localizationRepository: di<LocalizationRepository>()),
  );
  di.registerLazySingleton<SetLocaleUsecase>(
    () =>
        SetLocaleUsecase(localizationRepository: di<LocalizationRepository>()),
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
  di.registerFactory<CheckSessionCubit>(
    () => CheckSessionCubit(
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
  di.registerFactory<DeleteLocationsCubit>(
    () => DeleteLocationsCubit(
      deleteLocationsUsecase: di<DeleteLocationsUsecase>(),
    ),
  );
  di.registerFactory<SearchLocationsCubit>(() => SearchLocationsCubit());
  di.registerFactoryParam<UpdateLocationFormCubit, String, void>(
    (locationId, _) => UpdateLocationFormCubit(
      updateLocationUsecase: di<UpdateLocationUsecase>(),
      locationId: locationId,
    ),
  );
  di.registerFactory<AddDeliveryRouteFormCubit>(
    () => AddDeliveryRouteFormCubit(
      addDeliveryRouteUsecase: di<AddDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<GetDeliveryRoutesCubit>(
    () => GetDeliveryRoutesCubit(
      getDeliveryRoutesUsecase: di<GetDeliveryRoutesUsecase>(),
    ),
  );
  di.registerFactory<SearchDeliveryRoutesCubit>(
    () => SearchDeliveryRoutesCubit(),
  );
  di.registerFactory<UpdateDeliveryRouteFormCubit>(
    () => UpdateDeliveryRouteFormCubit(
      updateDeliveryRouteUsecase: di<UpdateDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<DeleteDeliveryRoutesCubit>(
    () => DeleteDeliveryRoutesCubit(
      deleteDeliveryRoutesUsecase: di<DeleteDeliveryRoutesUsecase>(),
    ),
  );
  di.registerFactoryParam<AddDeliveryOrderFormCubit, String, void>(
    (deliveryRouteId, _) => AddDeliveryOrderFormCubit(
      deliveryRouteId: deliveryRouteId,
      addDeliveryOrderUsecase: di<AddDeliveryOrderUsecase>(),
    ),
  );
  di.registerFactory<GetLocationSuggestionsCubit>(
    () => GetLocationSuggestionsCubit(
      getLocationSuggestionsUsecase: di<GetLocationSuggestionsUsecase>(),
    ),
  );
  di.registerFactoryParam<UpdateDeliveryOrderFormCubit, String, String>(
    (deliveryRouteId, deliveryOrderId) => UpdateDeliveryOrderFormCubit(
      deliveryRouteId: deliveryRouteId,
      deliveryOrderId: deliveryOrderId,
      updateDeliveryOrderUsecase: di<UpdateDeliveryOrderUsecase>(),
    ),
  );
  di.registerFactory<DeleteDeliveryOrdersCubit>(
    () => DeleteDeliveryOrdersCubit(
      deleteDeliveryOrdersUsecase: di<DeleteDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<GetProfileCubit>(
    () => GetProfileCubit(getProfileUsecase: di<GetProfileUsecase>()),
  );
  di.registerFactory<RecheckDeliveryOrdersCubit>(
    () => RecheckDeliveryOrdersCubit(
      recheckDeliveryOrdersUsecase: di<RecheckDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<SelectionCubit<String>>(() => SelectionCubit<String>());
  di.registerFactory<ConfirmDeliveryOrdersCubit>(
    () => ConfirmDeliveryOrdersCubit(
      confirmDeliveryOrdersUsecase: di<ConfirmDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<DeliveryOrderPageCubit>(() => DeliveryOrderPageCubit());
  di.registerFactory<TransitionRouteToSortingCubit>(
    () => TransitionRouteToSortingCubit(
      updateDeliveryRouteUsecase: di<UpdateDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<TransitionRouteToPendingCubit>(
    () => TransitionRouteToPendingCubit(
      updateDeliveryRouteUsecase: di<UpdateDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<SortDeliveryOrdersCubit>(
    () => SortDeliveryOrdersCubit(
      sortDeliveryOrdersUsecase: di<SortDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<ConfirmSortedDeliveryOrdersCubit>(
    () => ConfirmSortedDeliveryOrdersCubit(
      confirmSortedDeliveryOrdersUsecase:
          di<ConfirmSortedDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<TransitionRouteToDeliveringCubit>(
    () => TransitionRouteToDeliveringCubit(
      updateDeliveryRouteUsecase: di<UpdateDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<ConfirmDeliveredOrderCubit>(
    () => ConfirmDeliveredOrderCubit(
      updateDeliveryOrderUsecase: di<UpdateDeliveryOrderUsecase>(),
    ),
  );
  di.registerFactory<ConfirmCancelledOrderCubit>(
    () => ConfirmCancelledOrderCubit(
      updateDeliveryOrderUsecase: di<UpdateDeliveryOrderUsecase>(),
    ),
  );
  di.registerFactory<ConfirmRescheduledOrderCubit>(
    () => ConfirmRescheduledOrderCubit(
      updateDeliveryOrderUsecase: di<UpdateDeliveryOrderUsecase>(),
    ),
  );
  di.registerFactory<TransitionRouteToCompletedCubit>(
    () => TransitionRouteToCompletedCubit(
      updateDeliveryRouteUsecase: di<UpdateDeliveryRouteUsecase>(),
    ),
  );
  di.registerFactory<CreateDeliveryRouteWithOrdersCubit>(
    () => CreateDeliveryRouteWithOrdersCubit(
      createDeliveryRouteWithOrdersUsecase:
          di<CreateDeliveryRouteWithOrdersUsecase>(),
    ),
  );
  di.registerFactory<SearchDeliveryOrdersCubit>(
    () => SearchDeliveryOrdersCubit(
      getDeliveryOrdersUsecase: di<GetDeliveryOrdersUsecase>(),
    ),
  );
  di.registerFactory<SignoutCubit>(
    () => SignoutCubit(signoutUsecase: di<SignoutUsecase>()),
  );
  di.registerFactory<SubscriptionPurchaseCubit>(
    () => SubscriptionPurchaseCubit(
      verifySubscriptionUsecase: di<VerifySubscriptionUsecase>(),
    ),
  );
  di.registerFactory<GetCurrentPlanCubit>(
    () => GetCurrentPlanCubit(
      getCurrentSubscriptionUsecase: di<GetCurrentSubscriptionUsecase>(),
    ),
  );
  di.registerFactory<UpdateProfileFormCubit>(
    () => UpdateProfileFormCubit(
      updateProfileUsecase: di<UpdateProfileUsecase>(),
    ),
  );
  di.registerFactory<GetShareLocationUrlCubit>(
    () => GetShareLocationUrlCubit(
      getShareLocationUrlUsecase: di<GetShareLocationUrlUsecase>(),
    ),
  );
  di.registerFactory<GetLocaleCubit>(
    () => GetLocaleCubit(getLocaleUsecase: di<GetLocaleUsecase>()),
  );
  di.registerFactory<SetLocaleCubit>(
    () => SetLocaleCubit(setLocaleUsecase: di<SetLocaleUsecase>()),
  );
}
