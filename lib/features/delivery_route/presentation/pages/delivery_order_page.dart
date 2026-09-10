import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/utils/external_url_util.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_cancelled_order/confirm_cancelled_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_cancelled_order/confirm_cancelled_order_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivered_order/confirm_delivered_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivered_order/confirm_delivered_order_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_rescheduled_order/confirm_rescheduled_order_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_rescheduled_order/confirm_rescheduled_order_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_sorted_delivery_orders/confirm_sorted_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_sorted_delivery_orders/confirm_sorted_delivery_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/create_delivery_route_with_orders/create_delivery_route_with_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/create_delivery_route_with_orders/create_delivery_route_with_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_completed/transition_route_to_completed_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_completed/transition_route_to_completed_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_delivering/transition_route_to_delivering_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_delivering/transition_route_to_delivering_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_state.dart';
import 'package:smgo/features/delivery_route/presentation/widgets/option_button.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_cubit.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_state.dart';
import 'package:smgo/shared/utils/app_audio_utils.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:smgo/shared/presentation/widgets/smgo_generic_scan_screen.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_checkbox.dart';
import 'package:smgo/shared/presentation/widgets/smgo_loading_screen.dart';
import 'package:smgo/shared/utils/app_location_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteColors {
  static const green = Color(0xFF008C45);
  static const greenDark = Color(0xFF007A3D);
  static const greenLight = Color(0xFFEAF7F0);

  static const blue = Color(0xFF1976D2);
  static const blueLight = Color(0xFFEAF3FF);

  static const orange = Color(0xFFFFA000);
  static const orangeLight = Color(0xFFFFF6E5);

  static const red = Color(0xFFE53935);

  static const text = Color(0xFF18224A);
  static const secondaryText = Color(0xFF6F758A);
  static const border = Color(0xFFE9EBF0);
}

class DeliveryOrderPage extends StatefulWidget {
  const DeliveryOrderPage({super.key});

  @override
  State<DeliveryOrderPage> createState() => _DeliveryOrderPageState();
}

class _DeliveryOrderPageState extends State<DeliveryOrderPage> {
  late DeliveryRouteEntity deliveryRoute;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final extra = GoRouterState.of(context).extra as Map<String, Object>;
      deliveryRoute = extra['DeliveryRouteData'] as DeliveryRouteEntity;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final getDeliveryRoutesCubitInDRDP =
        extra['GetDeliveryRoutesCubitInDRDP'] != null
        ? extra['GetDeliveryRoutesCubitInDRDP'] as GetDeliveryRoutesCubit
        : null;
    final getDeliveryRoutesUsecaseParamsInDRDP =
        extra['GetDeliveryRoutesUsecaseParamsInDRDP'] != null
        ? extra['GetDeliveryRoutesUsecaseParamsInDRDP']
              as GetDeliveryRoutesUsecaseParams
        : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider<DeliveryOrderPageCubit>(
          create: (context) => di<DeliveryOrderPageCubit>(),
        ),
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (context) => di<GetDeliveryRoutesCubit>()
            ..call(
              params: GetDeliveryRoutesUsecaseParams(
                pageNumber: 1,
                pageSize: 1,
                id: deliveryRoute.id,
              ),
            ),
        ),
        BlocProvider<RecheckDeliveryOrdersCubit>(
          create: ((context) => di<RecheckDeliveryOrdersCubit>()),
        ),
        BlocProvider<SelectionCubit<String>>(
          create: (context) => di<SelectionCubit<String>>(),
        ),
        BlocProvider<ConfirmDeliveryOrdersCubit>(
          create: ((context) => di<ConfirmDeliveryOrdersCubit>()),
        ),
        BlocProvider<TransitionRouteToSortingCubit>(
          create: ((context) => di<TransitionRouteToSortingCubit>()),
        ),
        BlocProvider<TransitionRouteToPendingCubit>(
          create: ((context) => di<TransitionRouteToPendingCubit>()),
        ),
        BlocProvider<SortDeliveryOrdersCubit>(
          create: ((context) => di<SortDeliveryOrdersCubit>()),
        ),
        BlocProvider<ConfirmSortedDeliveryOrdersCubit>(
          create: ((context) => di<ConfirmSortedDeliveryOrdersCubit>()),
        ),
        BlocProvider<TransitionRouteToDeliveringCubit>(
          create: ((context) => di<TransitionRouteToDeliveringCubit>()),
        ),
        BlocProvider<TransitionRouteToCompletedCubit>(
          create: ((context) => di<TransitionRouteToCompletedCubit>()),
        ),
        BlocProvider<CreateDeliveryRouteWithOrdersCubit>(
          create: ((context) => di<CreateDeliveryRouteWithOrdersCubit>()),
        ),
        BlocProvider.value(
          value: di<GetProfileCubit>()..call(),
        ),
        BlocProvider<ConfirmSortedDeliveryOrdersCubit>(
          create: (_) => di<ConfirmSortedDeliveryOrdersCubit>(),
        ),
        BlocProvider<ConfirmDeliveredOrderCubit>(
          create: (_) => di<ConfirmDeliveredOrderCubit>(),
        ),
        BlocProvider<ConfirmCancelledOrderCubit>(
          create: (_) => di<ConfirmCancelledOrderCubit>(),
        ),
        BlocProvider<ConfirmRescheduledOrderCubit>(
          create: (_) => di<ConfirmRescheduledOrderCubit>(),
        ),
      ],
      child: BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
        builder: (_, _) =>
            BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
              listener: (_, state) {
                if (state is GetDeliveryRoutesDone) {
                  if (state.routes.isNotEmpty) {
                    setState(() {
                      deliveryRoute = state.routes.first;
                    });
                  }
                  if (getDeliveryRoutesCubitInDRDP != null &&
                      getDeliveryRoutesUsecaseParamsInDRDP != null) {
                    getDeliveryRoutesCubitInDRDP.call(
                      params: getDeliveryRoutesUsecaseParamsInDRDP,
                    );
                  }
                }
              },
              builder: (context, state) => Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.white,
                    body: RefreshIndicator(
                      onRefresh: () async {
                        await context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      },
                      child: CustomScrollView(
                        physics: const RefreshOnlyScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: IntrinsicHeight(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 100),
                                    child: RouteHeader(
                                      deliveryRoute: deliveryRoute,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: RouteSummary(
                                      deliveryRoute: deliveryRoute,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SliverFillRemaining(
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: RouteProgress(
                                    deliveryRoute: deliveryRoute,
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: _buildSelectionHeader(
                                    context: context,
                                  ),
                                ),
                                SliverFillRemaining(
                                  hasScrollBody:
                                      true, // Cho phép TabBarView cuộn bên trong
                                  child: _buildStatusContent(context: context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: _RouteActionBar(
                      route: deliveryRoute,
                      context: context,
                    ),
                  ),

                  // Loading
                  BlocConsumer<
                    RecheckDeliveryOrdersCubit,
                    RecheckDeliveryOrdersState
                  >(
                    listener: (context, state) {
                      if (state is RecheckDeliveryOrdersDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        context
                            .read<SelectionCubit<String>>()
                            .closeSelectionMode();
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPRecheckOrdersSuccessTitle.tr(),
                          subtitle: AppStrings.dOPRecheckOrdersSuccessContent
                              .tr(),
                        );
                      } else if (state is RecheckDeliveryOrdersFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPRecheckOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is RecheckDeliveryOrdersLoading,
                    ),
                  ),

                  BlocConsumer<
                    ConfirmDeliveryOrdersCubit,
                    ConfirmDeliveryOrdersState
                  >(
                    listener: (context, state) {
                      final selectionCubit = context
                          .read<SelectionCubit<String>>();
                      if (state is ConfirmDeliveryOrdersDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersSuccessTitle.tr(),
                          subtitle: AppStrings.dOPConfirmOrdersSuccessContent
                              .tr(
                                namedArgs: {
                                  'quantity': selectionCubit
                                      .state
                                      .selectedItems
                                      .length
                                      .toString(),
                                },
                              ),
                        );
                        selectionCubit.closeSelectionMode();
                      } else if (state is ConfirmDeliveryOrdersFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmDeliveryOrdersLoading,
                    ),
                  ),

                  BlocConsumer<
                    TransitionRouteToSortingCubit,
                    TransitionRouteToSortingState
                  >(
                    listener: (context, state) {
                      if (state is TransitionRouteToSortingDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is TransitionRouteToSortingFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is TransitionRouteToSortingLoading,
                    ),
                  ),

                  BlocConsumer<
                    TransitionRouteToPendingCubit,
                    TransitionRouteToPendingState
                  >(
                    listener: (context, state) {
                      if (state is TransitionRouteToPendingDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is TransitionRouteToPendingFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is TransitionRouteToPendingLoading,
                    ),
                  ),

                  BlocConsumer<
                    SortDeliveryOrdersCubit,
                    SortDeliveryOrdersState
                  >(
                    listener: (context, state) {
                      if (state is SortDeliveryOrdersDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is SortDeliveryOrdersFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is SortDeliveryOrdersLoading,
                    ),
                  ),

                  BlocConsumer<
                    ConfirmSortedDeliveryOrdersCubit,
                    ConfirmSortedDeliveryOrdersState
                  >(
                    listener: (context, state) {
                      if (state is ConfirmSortedDeliveryOrdersDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is ConfirmSortedDeliveryOrdersFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmSortedDeliveryOrdersLoading,
                    ),
                  ),

                  BlocConsumer<
                    TransitionRouteToDeliveringCubit,
                    TransitionRouteToDeliveringState
                  >(
                    listener: (context, state) {
                      if (state is TransitionRouteToDeliveringDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is TransitionRouteToDeliveringFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is TransitionRouteToDeliveringLoading,
                    ),
                  ),

                  BlocConsumer<
                    TransitionRouteToCompletedCubit,
                    TransitionRouteToCompletedState
                  >(
                    listener: (context, state) {
                      if (state is TransitionRouteToCompletedDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                      } else if (state is TransitionRouteToCompletedFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPActionFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is TransitionRouteToCompletedLoading,
                    ),
                  ),

                  BlocConsumer<
                    CreateDeliveryRouteWithOrdersCubit,
                    CreateDeliveryRouteWithOrdersState
                  >(
                    listener: (context, state) {
                      if (state is CreateDeliveryRouteWithOrdersDone) {
                        context.pushNamed(
                          AppRouteNames.deliveryOrder,
                          pathParameters: {'id': state.newDeliveryRoute.id},
                          extra: <String, Object>{
                            'DeliveryRouteData': state.newDeliveryRoute,
                          },
                        );
                      } else if (state is CreateDeliveryRouteWithOrdersFailed) {
                        if (state.error is DioException &&
                            (state.error as DioException)
                                    .response
                                    ?.data?['error']?['code'] ==
                                'ORDER_LIMIT_EXCEEDED') {
                          AppDialogUtils.showCustomDialog(
                            context: context,
                            title: AppStrings.dOPUpgradePackageTitle.tr(),
                            subtitle: AppStrings.dOPOrderLimitExceededContent
                                .tr(),
                            iconData: Icons.rocket_launch_outlined,
                            actions: [
                              SmgoButton(
                                onPressed: () {
                                  context.pop();
                                  context.pushNamed(AppRouteNames.subscription);
                                },
                                text: AppStrings.dOPUpgradeNowButtonLabel.tr(),
                                textColor: Colors.white,
                                primaryColor: AppColors.primary,
                              ),
                            ],
                          );
                          return;
                        }
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPCreateRouteFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is CreateDeliveryRouteWithOrdersLoading,
                    ),
                  ),

                  // Loading cho xác nhận đã sắp xếp
                  BlocConsumer<
                    ConfirmSortedDeliveryOrdersCubit,
                    ConfirmSortedDeliveryOrdersState
                  >(
                    listener: (context, state) {
                      if (state is ConfirmSortedDeliveryOrdersDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersSuccessContent.tr(),
                        );
                      } else if (state is ConfirmSortedDeliveryOrdersFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmSortedDeliveryOrdersLoading,
                    ),
                  ),

                  // Loading cho xác nhận giao thành công
                  BlocConsumer<
                    ConfirmDeliveredOrderCubit,
                    ConfirmDeliveredOrderState
                  >(
                    listener: (context, state) {
                      if (state is ConfirmDeliveredOrderDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersSuccessContent.tr(),
                        );
                      } else if (state is ConfirmDeliveredOrderFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmDeliveredOrderLoading,
                    ),
                  ),

                  // Loading cho xác nhận giao thất bại
                  BlocConsumer<
                    ConfirmCancelledOrderCubit,
                    ConfirmCancelledOrderState
                  >(
                    listener: (context, state) {
                      if (state is ConfirmCancelledOrderDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersSuccessContent.tr(),
                        );
                      } else if (state is ConfirmCancelledOrderFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmCancelledOrderLoading,
                    ),
                  ),

                  // Loading cho xác nhận hẹn giao sau
                  BlocConsumer<
                    ConfirmRescheduledOrderCubit,
                    ConfirmRescheduledOrderState
                  >(
                    listener: (context, state) {
                      if (state is ConfirmRescheduledOrderDone) {
                        context.read<GetDeliveryRoutesCubit>().call(
                          params: GetDeliveryRoutesUsecaseParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: deliveryRoute.id,
                          ),
                        );
                        AppDialogUtils.showSuccess(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersSuccessContent.tr(),
                        );
                      } else if (state is ConfirmRescheduledOrderFailed) {
                        AppDialogUtils.showError(
                          context: context,
                          title: AppStrings.dOPConfirmOrdersFailedTitle.tr(),
                          subtitle: AppStrings.dOPCommonErrorContent.tr(),
                        );
                      }
                    },
                    builder: (context, state) => SmgoLoadingScreen(
                      isLoading: state is ConfirmRescheduledOrderLoading,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  /// Thanh chọn tất cả & đếm số lượng
  Widget _buildSelectionHeader({required BuildContext context}) {
    final selectionCubit = context.read<SelectionCubit<String>>();
    final deliveryOrderPageCubit = context.read<DeliveryOrderPageCubit>();

    bool isAllSelectedInThisTab = false;
    List<DeliveryOrderEntity> currentOrders = [];

    if (deliveryOrderPageCubit.state.selectedTab ==
        DeliveryOrderPageTab.pending) {
      currentOrders = deliveryRoute.orders
          .where((order) => order.status == DeliveryOrderStatus.pending.value)
          .toList();
      isAllSelectedInThisTab =
          currentOrders.isNotEmpty &&
          currentOrders.every(
            (e) => selectionCubit.state.selectedItems.contains(e.id),
          );
    } else if (deliveryOrderPageCubit.state.selectedTab ==
        DeliveryOrderPageTab.checked) {
      currentOrders = deliveryRoute.orders
          .where((order) => order.status == DeliveryOrderStatus.checked.value)
          .toList();
      isAllSelectedInThisTab =
          currentOrders.isNotEmpty &&
          currentOrders.every(
            (e) => selectionCubit.state.selectedItems.contains(e.id),
          );
    } else if (deliveryOrderPageCubit.state.selectedTab ==
        DeliveryOrderPageTab.completedRescheduled) {
      currentOrders = deliveryRoute.orders
          .where(
            (order) => order.status == DeliveryOrderStatus.rescheduled.value,
          )
          .toList();
      isAllSelectedInThisTab =
          currentOrders.isNotEmpty &&
          currentOrders.every(
            (e) => selectionCubit.state.selectedItems.contains(e.id),
          );
    }

    if (selectionCubit.state.isEnabled &&
        (deliveryRoute.status == DeliveryRouteStatus.pending.value ||
            (deliveryRoute.status == DeliveryRouteStatus.completed.value &&
                context.read<DeliveryOrderPageCubit>().state.selectedTab ==
                    DeliveryOrderPageTab.completedRescheduled))) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => selectionCubit.toggleSelectAll(
                currentItems: deliveryRoute.orders
                    .map((order) => order.id)
                    .toList(),
              ),
              child: Row(
                children: [
                  SmgoCheckbox(
                    primaryColor: AppColors.primary,
                    value: isAllSelectedInThisTab,
                    onChanged: (_) => selectionCubit.toggleSelectAll(
                      currentItems: currentOrders
                          .map((order) => order.id)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.dOPSelectAllBtnLabel.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Text(
              AppStrings.dOPSelectedOrdersCountContent.tr(
                namedArgs: {
                  'quantity': selectionCubit.state.selectedItems.length
                      .toString(),
                },
              ),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildStatusContent({required BuildContext context}) {
    if (deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return PendingView(deliveryRoute: deliveryRoute, context: context);
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return SortingView(deliveryRoute: deliveryRoute);
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return DeliveringView(deliveryRoute: deliveryRoute);
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return CompletedView(deliveryRoute: deliveryRoute, context: context);
    } else {
      throw Exception(
        'The delivery route status does not match any valid values',
      );
    }
  }
}

// Header
class RouteHeader extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteHeader({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
      builder: (context, state) {
        final selectionCubit = context.read<SelectionCubit<String>>();

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 55, 12, 25),
          decoration: const BoxDecoration(
            color: RouteColors.green,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              if (state.isEnabled &&
                  deliveryRoute.status == DeliveryRouteStatus.pending.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: selectionCubit.closeSelectionMode,
                    ),
                    Text(
                      AppStrings.dOPHeaderSelectedOrdersCountContent.tr(
                        namedArgs: {
                          'selectedCount': state.selectedItems.length
                              .toString(),
                        },
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final parentContext = context;
                        AppDialogUtils.showCustomDialog(
                          context: context,
                          iconData: Icons.delete_forever,
                          title: AppStrings.dOPDeleteSelectedOrdersDialogTitle
                              .tr(),
                          subtitle: AppStrings
                              .dOPDeleteSelectedOrdersDialogContent
                              .tr(
                                namedArgs: {
                                  'quantity': state.selectedItems.length
                                      .toString(),
                                },
                              ),
                          barrierDismissible: false,
                          actions: [
                            BlocProvider<DeleteDeliveryOrdersCubit>(
                              create: (context) =>
                                  di<DeleteDeliveryOrdersCubit>(),
                              child:
                                  BlocConsumer<
                                    DeleteDeliveryOrdersCubit,
                                    DeleteDeliveryOrdersState
                                  >(
                                    listener: (context, state) {
                                      if (state is DeleteDeliveryOrdersDone) {
                                        parentContext.pop();
                                        parentContext
                                            .read<GetDeliveryRoutesCubit>()
                                            .call(
                                              params:
                                                  GetDeliveryRoutesUsecaseParams(
                                                    pageNumber: 1,
                                                    pageSize: 1,
                                                    id: deliveryRoute.id,
                                                  ),
                                            );
                                        AppDialogUtils.showSuccess(
                                          context: parentContext,
                                          title: AppStrings
                                              .dOPDeleteOrderSuccessTitle
                                              .tr(),
                                          subtitle: AppStrings
                                              .dOPDeleteOrderSuccessContent
                                              .tr(
                                                namedArgs: {
                                                  'quantity': selectionCubit
                                                      .state
                                                      .selectedItems
                                                      .length
                                                      .toString(),
                                                },
                                              ),
                                        );

                                        selectionCubit.closeSelectionMode();
                                      } else if (state
                                          is DeleteDeliveryOrdersFailed) {
                                        parentContext.pop();
                                        AppDialogUtils.showError(
                                          context: parentContext,
                                          title: AppStrings
                                              .dOPDeleteOrderFailedTitle
                                              .tr(),
                                          subtitle: AppStrings
                                              .dOPDeleteOrderFailedContent
                                              .tr(),
                                        );
                                      }
                                    },
                                    builder: (context, state) => IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: SmgoButton(
                                              primaryColor: AppColors.primary,
                                              text: AppStrings
                                                  .dOPDeleteSelectedOrdersDialogCancelBtnTitle
                                                  .tr(),
                                              isOutlined: true,
                                              isDisabled:
                                                  state
                                                      is DeleteDeliveryOrdersLoading,
                                              onPressed: () {
                                                context.pop();
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SmgoButton(
                                              primaryColor: AppColors.primary,
                                              isDisabled:
                                                  state
                                                      is DeleteDeliveryOrdersLoading,
                                              onPressed: () {
                                                context
                                                    .read<
                                                      DeleteDeliveryOrdersCubit
                                                    >()
                                                    .call(
                                                      deliveryRouteId:
                                                          deliveryRoute.id,
                                                      deliveryOrderIds:
                                                          selectionCubit
                                                              .state
                                                              .selectedItems
                                                              .toList(),
                                                    );
                                              },
                                              child:
                                                  state
                                                      is DeleteDeliveryOrdersLoading
                                                  ? SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Text(
                                                      AppStrings
                                                          .dOPDeleteSelectedOrdersDialogDeleteBtnTitle
                                                          .tr(),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ],
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        AppStrings.dOPHeaderDeleteSelectedOrdersButtonLabel.tr(
                          namedArgs: {
                            'selectedCount': state.selectedItems.length
                                .toString(),
                          },
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: () {
                        context.pop();
                      },
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            deliveryRoute.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            AppStrings.dOPCreatedAtContent.tr(
                              namedArgs: {
                                'date': DateFormat(
                                  'dd/MM/yyyy • HH:mm',
                                ).format(deliveryRoute.createdAt),
                              },
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 22),
                  ],
                ),

              const SizedBox(height: 20),

              _SearchBox(deliveryRoute: deliveryRoute),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// Thanh search
class _SearchBox extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const _SearchBox({required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () => context.pushNamed(
        AppRouteNames.searchDeliveryOrder,
        pathParameters: {'id': deliveryRoute.id},
        extra: <String, Object>{
          'DeliveryRouteDataInDOP': deliveryRoute,
          'GetDeliveryRoutesCubitInDOP': context.read<GetDeliveryRoutesCubit>(),
          'GetDeliveryRoutesUsecaseParamsInDOP': GetDeliveryRoutesUsecaseParams(
            id: deliveryRoute.id,
            pageNumber: 1,
            pageSize: 1,
          ),
        },
      ),
      readOnly: true,
      style: const TextStyle(color: RouteColors.text, fontSize: 16),
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        hintText: AppStrings.dOPSearchOrdersHint.tr(),
        hintStyle: const TextStyle(color: Color(0xFF9AA0B3), fontSize: 16),
        prefixIcon: const Icon(Icons.search, size: 28, color: RouteColors.text),
        suffixIcon: IconButton(
          onPressed: () {
            _openOrderScanScreenToFindOrder(context: context);
          },
          icon: const Icon(Icons.qr_code_scanner, color: RouteColors.green),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _openOrderScanScreenToFindOrder({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return deliveryRoute.orders
                  .where((order) => order.orderCode == rawValue)
                  .firstOrNull;
            }
            return null;
          },
          itemBuilder: (_, order) {
            if (order == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.1 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.dOPOrderNotFoundTitle.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.dOPOrderNotFoundContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006837),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.dOPScanAnotherCodeButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.view_column,
                        AppStrings.dOPOrderCodeLabel.tr(),
                        order.orderCode,
                        showCopy: true,
                        context: context,
                      ),

                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.inventory_2_outlined,
                        AppStrings.dOPProductNameLabel.tr(),
                        order.orderName?.isNotEmpty == true
                            ? order.orderName!
                            : AppStrings.dOPNoOrderName.tr(),
                        showCopy: true,
                        context: context,
                      ),

                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.person_outline,
                        AppStrings.dOPRecipientNameLabel.tr(),
                        order.contactName,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.phone_outlined,
                        AppStrings.dOPPhoneNumberLabel.tr(),
                        order.contactPhone,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.location_on_outlined,
                        AppStrings.dOPDeliveryAddressLabel.tr(),
                        order.address,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildImageRow(
                        AppStrings.dOPOrderImageLabel.tr(),
                        order.orderMediaUrl ?? '',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SmgoButton(
                          primaryColor: AppColors.primary,
                          onPressed: () {
                            context.pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.dOPRescanButtonLabel.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SmgoButton(
                          primaryColor: AppColors.primary,
                          onPressed: () {
                            context.pop();
                            context.pop();
                            context.pushNamed(
                              AppRouteNames.deliveryOrderDetail,
                              pathParameters: {
                                'id': order.deliveryRouteId,
                                'deliveryOrderId': order.id,
                              },
                              extra: <String, Object>{
                                'DeliveryRouteData': deliveryRoute,
                                'DeliveryOrderData': order,
                                'GetDeliveryRoutesCubitInDOP': context
                                    .read<GetDeliveryRoutesCubit>(),
                                'GetDeliveryRoutesUsecaseParamsInDOP':
                                    GetDeliveryRoutesUsecaseParams(
                                      id: deliveryRoute.id,
                                      pageNumber: 1,
                                      pageSize: 1,
                                    ),
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.dOPViewDetailButtonLabel.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onComplete: (_, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }
}

// Summary
class RouteSummary extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteSummary({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final familarCount = deliveryRoute.orders
        .where(
          (order) =>
              order.appliedLocation != null &&
              order.appliedLocation!.userId ==
                  context.read<GetProfileCubit>().state.profile?.id,
        )
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SummaryItem(
              title: AppStrings.dOPTotalOrdersTitle.tr(),
              value: '${deliveryRoute.totalOrders}',
              subtitle: AppStrings.dOPOrderUnit.tr(),
            ),
          ),

          _divider(),

          Expanded(child: _buildProgressSummary()),

          _divider(),

          Expanded(
            child: _SummaryItem(
              title: AppStrings.dOPFamiliarCustomerTitle.tr(),
              value: '$familarCount',
              subtitle: AppStrings.dOPOrderPercentageContent.tr(
                namedArgs: {
                  'percentage':
                      (deliveryRoute.totalOrders > 0
                              ? ((familarCount / deliveryRoute.totalOrders) *
                                        100)
                                    .round()
                              : 0)
                          .toString(),
                },
              ),
              badge: true,
            ),
          ),

          _divider(),

          Expanded(child: _buildStatusSummary()),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    if (deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return _ProgressSummaryItem(
        title: AppStrings.dOPProgressTitle.tr(),
        progress: deliveryRoute.checkProgress,
        value: '${(deliveryRoute.checkProgress * 100).round()}%',
        subtitle:
            '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders}',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return _ProgressSummaryItem(
        title: AppStrings.dOPProgressTitle.tr(),
        progress: deliveryRoute.sortingProgress,
        value: '${(deliveryRoute.sortingProgress * 100).round()}%',
        subtitle:
            '${deliveryRoute.totalSortedOrders}/${deliveryRoute.totalOrders}',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return _ProgressSummaryItem(
        title: AppStrings.dOPProgressTitle.tr(),
        progress: deliveryRoute.deliveryProgress,
        value: '${(deliveryRoute.deliveryProgress * 100).round()}%',
        subtitle: AppStrings.dOPDeliveryProgressContent.tr(
          namedArgs: {
            'completed':
                (deliveryRoute.totalDeliveredOrders +
                        deliveryRoute.totalCancelledOrders +
                        deliveryRoute.totalRescheduledOrders)
                    .toString(),
            'total': deliveryRoute.totalOrders.toString(),
          },
        ),
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return _ProgressSummaryItem(
        title: AppStrings.dOPProgressTitle.tr(),
        progress: 1,
        value: '100%',
        subtitle: AppStrings.dOPTotalOrdersContent.tr(
          namedArgs: {'quantity': deliveryRoute.totalOrders.toString()},
        ),
      );
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }

  Widget _buildStatusSummary() {
    if (deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return _StatusSummaryItem(
        icon: Icons.check_circle_outline,
        color: RouteColors.green,
        text: AppStrings.dOPCheckingStatusLabel.tr(),
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return _StatusSummaryItem(
        icon: Icons.access_time,
        color: RouteColors.green,
        text: AppStrings.dOPSortingStatusLabel.tr(),
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return _StatusSummaryItem(
        icon: Icons.delivery_dining_rounded,
        color: RouteColors.green,
        text: AppStrings.dOPDeliveringStatusLabel.tr(),
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return _StatusSummaryItem(
        icon: Icons.check_circle_outline,
        color: RouteColors.green,
        text: AppStrings.dOPCompletedStatusLabel.tr(),
      );
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }

  Widget _divider() {
    return Container(width: 1, height: 95, color: RouteColors.border);
  }
}

// Summary item
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool badge;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: RouteColors.green,
          ),
        ),

        const SizedBox(height: 4),

        if (badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: RouteColors.greenLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: RouteColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            subtitle,
            style: const TextStyle(color: RouteColors.text, fontSize: 12),
          ),
      ],
    );
  }
}

// Progress summary
class _ProgressSummaryItem extends StatelessWidget {
  final String title;
  final double progress;
  final String value;
  final String subtitle;

  const _ProgressSummaryItem({
    required this.title,
    required this.progress,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),
        SizedBox(height: 14),
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: RouteColors.greenLight,
                valueColor: const AlwaysStoppedAnimation(RouteColors.green),
              ),

              Text(value, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: RouteColors.text),
        ),
      ],
    );
  }
}

// Status summary
class _StatusSummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.dOPStatusTitle.tr(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),

        const SizedBox(height: 12),

        Icon(icon, size: 32, color: color),

        const SizedBox(height: 8),

        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: RouteColors.text),
        ),
      ],
    );
  }
}

// Route progress
class RouteProgress extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteProgress({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final currentStep = _currentStep;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepItem(
              step: 1,
              title: AppStrings.dOPCheckOrdersStepTitle.tr(),
              subtitle: '',
              completed: currentStep > 1,
              active: currentStep == 1,
            ),

            _StepConnector(completed: currentStep > 2),

            _StepItem(
              step: 2,
              title: AppStrings.dOPSortGoodsStepTitle.tr(),
              subtitle: '',
              completed: currentStep > 2,
              active: currentStep == 2,
            ),

            _StepConnector(completed: currentStep > 3),

            _StepItem(
              step: 3,
              title: AppStrings.dOPDeliverStepTitle.tr(),
              subtitle: '',
              completed: currentStep > 3,
              active: currentStep == 3,
            ),

            _StepConnector(completed: currentStep >= 4),

            _StepItem(
              step: 4,
              title: AppStrings.dOPCompleteStepTitle.tr(),
              subtitle: '',
              completed: currentStep >= 4,
              active: currentStep == 4,
            ),
          ],
        ),
      ),
    );
  }

  int get _currentStep {
    if (deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return 1;
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return 2;
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return 3;
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return 4;
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }
}

// Step item
class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String? subtitle;
  final bool completed;
  final bool active;

  const _StepItem({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active
        ? RouteColors.green
        : const Color(0xFF9FA3B5);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? RouteColors.green
                  : active
                  ? RouteColors.greenLight
                  : Colors.transparent,
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white)
                : Icon(_icon, color: color),
          ),

          const SizedBox(height: 8),

          Text(
            '$step. $title',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active || completed
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: color,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _icon {
    switch (step) {
      case 1:
        return Icons.fact_check_outlined;
      case 2:
        return Icons.view_in_ar_outlined;
      case 3:
        return Icons.delivery_dining_outlined;
      case 4:
        return Icons.flag_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

// Step connector
class _StepConnector extends StatelessWidget {
  final bool completed;

  const _StepConnector({required this.completed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 3,
              color: completed ? RouteColors.green : const Color(0xFFB8BBC8),
            ),
          ),
        ),
      ),
    );
  }
}

// Pending
class PendingView extends StatefulWidget {
  final DeliveryRouteEntity deliveryRoute;
  final BuildContext context;

  const PendingView({
    super.key,
    required this.deliveryRoute,
    required this.context,
  });

  @override
  State<PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView>
    with SingleTickerProviderStateMixin {
  late BuildContext _parentContext;
  late DeliveryRouteEntity _deliveryRoute;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _parentContext = widget.context;
    _deliveryRoute = widget.deliveryRoute;
    _tabController = TabController(length: 2, vsync: this);
    _parentContext.read<DeliveryOrderPageCubit>().tabChanged(
      tab: DeliveryOrderPageTab.pending,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _parentContext.read<SelectionCubit<String>>().closeSelectionMode();

        // Cập nhật trạng thái ở cấp page
        _parentContext.read<DeliveryOrderPageCubit>().tabChanged(
          tab: _tabController.index == 0
              ? DeliveryOrderPageTab.pending
              : DeliveryOrderPageTab.checked,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PendingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.context != widget.context) {
        _parentContext = widget.context;
      }

      if (oldWidget.deliveryRoute != widget.deliveryRoute) {
        _deliveryRoute = widget.deliveryRoute;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo trạng thái
    final pendingOrders = _deliveryRoute.orders
        .where((o) => o.status == DeliveryOrderStatus.pending.value)
        .toList();
    final checkedOrders = _deliveryRoute.orders
        .where((o) => o.status == DeliveryOrderStatus.checked.value)
        .toList();

    return Column(
      children: [
        // 1. THANH TAB DỰA THEO THIẾT KẾ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.green,
            unselectedLabelColor: const Color(0xFF1E2440),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: [
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPPendingTabTitle.tr(),
                  count: pendingOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPCheckedTabTitle.tr(),
                  count: checkedOrders.length,
                ),
              ),
            ],
          ),
        ),

        // 2. NỘI DUNG DANH SÁCH VUỐT ĐƯỢC
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrderList(orders: pendingOrders, deliveryRoute: _deliveryRoute),
              _OrderList(orders: checkedOrders, deliveryRoute: _deliveryRoute),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget hiển thị Tiêu đề + Badge đếm số lượng
class _TabBadge extends StatelessWidget {
  final String title;
  final int count;

  const _TabBadge({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<DeliveryOrderEntity> orders;
  final DeliveryRouteEntity deliveryRoute;

  const _OrderList({required this.orders, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final selectionCubit = context.read<SelectionCubit<String>>();

    if (orders.isEmpty) {
      return Center(child: Text(AppStrings.dOPNoOrdersContent.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: orders[index],
          isSelectionMode: selectionCubit.state.isEnabled,
          isSelected: selectionCubit.state.selectedItems.contains(
            orders[index].id,
          ),
          onLongPress: () {
            if (deliveryRoute.status == DeliveryRouteStatus.pending.value ||
                (deliveryRoute.status == DeliveryRouteStatus.completed.value &&
                    context.read<DeliveryOrderPageCubit>().state.selectedTab ==
                        DeliveryOrderPageTab.completedRescheduled)) {
              if (!selectionCubit.state.isEnabled) {
                selectionCubit.toggleSelection(item: orders[index].id);
              }
            }
          },
          onCheckboxChanged: (value) {
            selectionCubit.toggleSelection(item: orders[index].id);
          },
          onTap: () {
            if (!selectionCubit.state.isEnabled) {
              context.pushNamed(
                AppRouteNames.deliveryOrderDetail,
                pathParameters: {
                  'id': orders[index].deliveryRouteId,
                  'deliveryOrderId': orders[index].id,
                },
                extra: <String, Object>{
                  'DeliveryRouteData': deliveryRoute,
                  'DeliveryOrderData': orders[index],
                  'GetDeliveryRoutesCubitInDOP': context
                      .read<GetDeliveryRoutesCubit>(),
                  'GetDeliveryRoutesUsecaseParamsInDOP':
                      GetDeliveryRoutesUsecaseParams(
                        id: deliveryRoute.id,
                        pageNumber: 1,
                        pageSize: 1,
                      ),
                },
              );
            } else {
              selectionCubit.toggleSelection(item: orders[index].id);
            }
          },
        );
      },
    );
  }
}

// Sort order
class SortingView extends StatefulWidget {
  final DeliveryRouteEntity deliveryRoute;

  const SortingView({super.key, required this.deliveryRoute});

  @override
  State<SortingView> createState() => _SortingViewState();
}

class _SortingViewState extends State<SortingView> {
  late DeliveryRouteEntity _deliveryRoute;

  @override
  void initState() {
    super.initState();
    _deliveryRoute = widget.deliveryRoute;
  }

  @override
  void didUpdateWidget(covariant SortingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.deliveryRoute != widget.deliveryRoute) {
        _deliveryRoute = widget.deliveryRoute;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var sortedOrders = _deliveryRoute.orders;
    if (_deliveryRoute.isAllOrdersRouted) {
      sortedOrders.sort((a, b) => b.sequenceOrder! - a.sequenceOrder!);
    }
    var uniqueOrderCodeSuffixs = _getUniqueOrderSuffixes(sortedOrders);

    return Column(
      children: [
        const _SortingGuide(),
        TotalDistanceCard(
          distanceText:
              '${_deliveryRoute.isAllOrdersRouted ? ((_deliveryRoute.totalDistance ?? 0) / 1000).toStringAsFixed(2) : '----'} km',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sortedOrders.length,
            itemBuilder: (context, index) => SortingOrderCard(
              status:
                  sortedOrders[index].status ==
                      DeliveryOrderStatus.checked.value
                  ? (_deliveryRoute.currentNeedSortOrder?.id ==
                            sortedOrders[index].id
                        ? SortingOrderStatus.current
                        : SortingOrderStatus.unsorted)
                  : sortedOrders[index].status ==
                        DeliveryOrderStatus.sorted.value
                  ? SortingOrderStatus.sorted
                  : SortingOrderStatus.current,
              order: sortedOrders[index],
              uniqueOrderCodeSuffix:
                  uniqueOrderCodeSuffixs[sortedOrders[index].id]!,
              deliveryRoute: _deliveryRoute,
              onTap: () {
                context.pushNamed(
                  AppRouteNames.deliveryOrderDetail,
                  pathParameters: {
                    'id': sortedOrders[index].deliveryRouteId,
                    'deliveryOrderId': sortedOrders[index].id,
                  },
                  extra: <String, Object>{
                    'DeliveryRouteData': _deliveryRoute,
                    'DeliveryOrderData': sortedOrders[index],
                    'GetDeliveryRoutesCubitInDOP': context
                        .read<GetDeliveryRoutesCubit>(),
                    'GetDeliveryRoutesUsecaseParamsInDOP':
                        GetDeliveryRoutesUsecaseParams(
                          id: _deliveryRoute.id,
                          pageNumber: 1,
                          pageSize: 1,
                        ),
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TotalDistanceCard extends StatelessWidget {
  final String distanceText;
  final VoidCallback? onInfoPressed;

  const TotalDistanceCard({
    super.key,
    required this.distanceText,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // Giảm padding card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RouteColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon đường cao tốc bên trái (thu nhỏ lại)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: RouteColors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Tiêu đề và số km (thu nhỏ font size)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.dOPEstimatedTotalDistanceTitle.tr(),
                      style: TextStyle(
                        fontSize: 11, // Giảm từ 13 xuống 11
                        fontWeight: FontWeight.w500,
                        color: RouteColors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onInfoPressed ?? () {},
                      child: const Icon(
                        Icons.info_outline,
                        size: 13, // Giảm kích thước icon info
                        color: RouteColors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  distanceText,
                  style: const TextStyle(
                    fontSize: 18, // Giảm từ 22 xuống 18
                    fontWeight: FontWeight.w700,
                    color: RouteColors.green,
                  ),
                ),
              ],
            ),
          ),

          // Minh họa icon bản đồ / đường đi đứt nét ở góc phải (thu nhỏ size canvas từ 80x40 xuống 60x30)
          CustomPaint(size: const Size(60, 30), painter: _DottedRoutePainter()),
        ],
      ),
    );
  }
}

class _DottedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RouteColors.green
      ..strokeWidth =
          1.5 // Giảm độ dày nét vẽ một chút cho mảnh và tinh tế hơn
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Tọa độ thu gọn lại phù hợp với kích thước Size(60, 30)
    final path = Path();
    path.moveTo(6, 22);
    path.cubicTo(18, 22, 22, 6, 38, 9);
    path.cubicTo(45, 10, 48, 9, 54, 6);

    // Tạo hiệu ứng nét đứt (dash line)
    final dashPath = Path();
    const dashLength = 3.0;
    const dashSpace = 2.5;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);

    // Vẽ điểm ghim vị trí (Marker) thứ nhất ở dưới trái
    _drawMarker(canvas, const Offset(6, 22));

    // Vẽ điểm ghim vị trí (Marker) thứ hai ở trên phải
    _drawMarker(canvas, const Offset(54, 6));
  }

  void _drawMarker(Canvas canvas, Offset position) {
    // Vòng mờ bên dưới marker (thu nhỏ lại)
    final shadowPaint = Paint()
      ..color = RouteColors.green.withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx, position.dy + 3),
        width: 8,
        height: 4,
      ),
      shadowPaint,
    );

    // Icon ghim vị trí xanh (thu nhỏ bán kính)
    final markerPaint = Paint()..color = RouteColors.green;
    canvas.drawCircle(position, 4, markerPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(position, 1.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SortingGuide extends StatefulWidget {
  const _SortingGuide();

  @override
  State<_SortingGuide> createState() => _SortingGuideState();
}

class _SortingGuideState extends State<_SortingGuide> {
  bool _isClosed = false;

  @override
  Widget build(BuildContext context) {
    if (_isClosed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RouteColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: RouteColors.orange,
            size: 22,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dOPSortingInstructionsTitle.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: RouteColors.text,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  AppStrings.dOPSortingInstructionsContent.tr(),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: RouteColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isClosed = true;
                });
              },
              icon: const Icon(
                Icons.close,
                color: RouteColors.orange,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final DeliveryOrderEntity order;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckboxChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            const SizedBox(width: 16),
            SmgoCheckbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              primaryColor: AppColors.primary,
            ),
          ],
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RouteColors.border),
              ),
              // Sử dụng ClipRRect để hiệu ứng gợn sóng không tràn ra ngoài đường viền bo góc
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onLongPress: onLongPress,
                    onTap: onTap, // 3. Gắn callback vào sự kiện bấm
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // CỘT BÊN TRÁI: Tự co dãn theo khoảng trống còn lại
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        order.orderCode,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: RouteColors.text,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _CustomerBadge(
                                      familiar:
                                          order.appliedLocation != null &&
                                          order.appliedLocation!.userId ==
                                              context
                                                  .read<GetProfileCubit>()
                                                  .state
                                                  .profile
                                                  ?.id,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _InfoRow(
                                  icon: Icons.person_outline,
                                  text: order.contactName,
                                ),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: order.contactPhone,
                                ),
                                _InfoRow(
                                  icon: Icons.shopping_bag_outlined,
                                  color:
                                      order.orderName != null &&
                                          order.orderName!.isNotEmpty
                                      ? RouteColors.text
                                      : Colors.grey,
                                  text:
                                      order.orderName != null &&
                                          order.orderName!.isNotEmpty
                                      ? order.orderName!
                                      : AppStrings.dOPNoOrderName.tr(),
                                ),
                                _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  text: order.address,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.chevron_right,
                                color: RouteColors.text,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = RouteColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RouteColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

enum SortingOrderStatus { sorted, unsorted, current }

class SortingOrderCardColors {
  // Trạng thái 1: Đã sắp xếp
  static const Color sortedBg = Color(0xFFE6F6EE);
  static const Color sortedContent = AppColors.primary;

  // Trạng thái 2: Chưa sắp xếp
  static const Color unsortedBg = Color(0xFFF3F4F6);
  static const Color unsortedContent = Color(0xFF6B7280);

  // Trạng thái 3: Hiện tại
  static const Color currentBorder = AppColors.primary;
  static const Color currentNumberBg = AppColors.primary;
  static const Color currentNumberText = Colors.white;

  // Badge "Đơn hiện tại" màu cam
  static const Color badgeCurrentBg = Color(0xFFFFF1E6);
  static const Color badgeCurrentText = Color(0xFFF97316);
}

class SortingOrderCard extends StatelessWidget {
  final DeliveryOrderEntity order;
  final SortingOrderStatus status; // Thêm thuộc tính trạng thái
  final VoidCallback? onTap;
  final String uniqueOrderCodeSuffix;
  final DeliveryRouteEntity deliveryRoute;

  const SortingOrderCard({
    super.key,
    required this.order,
    required this.status,
    this.onTap,
    required this.uniqueOrderCodeSuffix,
    required this.deliveryRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định màu viền và hiệu ứng bóng (glow) dựa theo trạng thái
    BoxDecoration boxDecoration = _getBoxDecoration();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: boxDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildNumberBox(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OrderCardContent(
                      order: order,
                      status: status,
                      uniqueOrderCodeSuffix: uniqueOrderCodeSuffix,
                      deliveryRoute: deliveryRoute,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: status == SortingOrderStatus.unsorted
                        ? SortingOrderCardColors.unsortedContent
                        : RouteColors.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() {
    if (status == SortingOrderStatus.current) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SortingOrderCardColors.currentBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: SortingOrderCardColors.currentBorder.withAlpha(
              (0.15 * 255).round(),
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RouteColors.border),
    );
  }

  Widget _buildNumberBox() {
    Color bgColor;
    Color textColor;

    switch (status) {
      case SortingOrderStatus.sorted:
        bgColor = SortingOrderCardColors.sortedBg;
        textColor = SortingOrderCardColors.sortedContent;
        break;
      case SortingOrderStatus.unsorted:
        bgColor = SortingOrderCardColors.unsortedBg;
        textColor = SortingOrderCardColors.unsortedContent;
        break;
      case SortingOrderStatus.current:
        bgColor = SortingOrderCardColors.currentNumberBg;
        textColor = SortingOrderCardColors.currentNumberText;
        break;
    }

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${order.sequenceOrder ?? '-'}',
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class OrderCardContent extends StatelessWidget {
  final DeliveryOrderEntity order;
  final SortingOrderStatus status;
  final String uniqueOrderCodeSuffix;
  final DeliveryRouteEntity deliveryRoute;

  const OrderCardContent({
    super.key,
    required this.order,
    required this.status,
    required this.uniqueOrderCodeSuffix,
    required this.deliveryRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: order.orderCode.substring(
                        0,
                        order.orderCode.length - uniqueOrderCodeSuffix.length,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: status == SortingOrderStatus.unsorted
                            ? SortingOrderCardColors.unsortedContent
                            : RouteColors.text,
                      ),
                    ),

                    TextSpan(
                      text: uniqueOrderCodeSuffix,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            status == SortingOrderStatus.current ||
                                status == SortingOrderStatus.sorted
                            ? AppColors.primary
                            : SortingOrderCardColors.unsortedContent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            _buildStatusBadge(),
          ],
        ),

        const SizedBox(height: 6),

        _infoRow(
          icon: Icons.person_outline,
          text: order.contactName,
          status: status,
        ),

        _infoRow(
          icon: Icons.shopping_bag_outlined,
          text: order.orderName != null && order.orderName!.isNotEmpty
              ? order.orderName!
              : AppStrings.dOPNoOrderName.tr(),
          status: status,
        ),

        _infoRow(
          icon: Icons.location_on_outlined,
          text: order.address,
          status: status,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    switch (status) {
      case SortingOrderStatus.sorted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: SortingOrderCardColors.sortedBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            AppStrings.dOPSortedStatusLabel.tr(),
            style: TextStyle(
              color: SortingOrderCardColors.sortedContent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case SortingOrderStatus.unsorted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: SortingOrderCardColors.unsortedBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            AppStrings.dOPUnsortedStatusLabel.tr(),
            style: TextStyle(
              color: SortingOrderCardColors.unsortedContent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case SortingOrderStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: SortingOrderCardColors.badgeCurrentBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_outline,
                size: 12,
                color: SortingOrderCardColors.badgeCurrentText,
              ),
              SizedBox(width: 4),
              Text(
                AppStrings.dOPNeedSortingStatusLabel.tr(),
                style: TextStyle(
                  color: SortingOrderCardColors.badgeCurrentText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    required SortingOrderStatus status,
  }) {
    final color = status == SortingOrderStatus.unsorted
        ? SortingOrderCardColors.unsortedContent
        : SortingOrderCardColors
              .sortedContent; // Hoặc dùng màu text thông thường tuỳ bạn chọn

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: status == SortingOrderStatus.unsorted
                    ? SortingOrderCardColors.unsortedContent
                    : RouteColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveringView extends StatefulWidget {
  final DeliveryRouteEntity deliveryRoute;

  const DeliveringView({super.key, required this.deliveryRoute});

  @override
  State<DeliveringView> createState() => _DeliveringViewState();
}

class _DeliveringViewState extends State<DeliveringView>
    with SingleTickerProviderStateMixin {
  late DeliveryRouteEntity _deliveryRoute;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _deliveryRoute = widget.deliveryRoute;
  }

  @override
  void didUpdateWidget(covariant DeliveringView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.deliveryRoute != widget.deliveryRoute) {
        _deliveryRoute = widget.deliveryRoute;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveredOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.delivered.value)
        .toList();
    final cancelledOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.cancelled.value)
        .toList();
    final rescheduledOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.rescheduled.value)
        .toList();

    return Column(
      children: [
        const _DeliveryInfoBanner(),

        SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Thêm dòng này để cho phép trượt ngang các tab
            tabAlignment: TabAlignment
                .start, // Canh trái các tab khi trượt (Flutter 3.16+)
            indicatorColor: Colors.green,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.green,
            unselectedLabelColor: const Color(0xFF1E2440),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: [
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPDeliveryRouteTabTitle.tr(),
                  count: _deliveryRoute.totalOrders,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPDeliveredTabTitle.tr(),
                  count: deliveredOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPCancelledTabTitle.tr(),
                  count: cancelledOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPRescheduledTabTitle.tr(),
                  count: rescheduledOrders.length,
                ),
              ),
            ],
          ),
        ),
        // 2. NỘI DUNG DANH SÁCH VUỐT ĐƯỢC
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DeliveringOrderList(
                deliveryRoute: _deliveryRoute,
                orders: _deliveryRoute.orders,
              ),
              _OrderList(
                orders: deliveredOrders,
                deliveryRoute: _deliveryRoute,
              ),
              _OrderList(
                orders: cancelledOrders,
                deliveryRoute: _deliveryRoute,
              ),
              _OrderList(
                orders: rescheduledOrders,
                deliveryRoute: _deliveryRoute,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryInfoBanner extends StatelessWidget {
  const _DeliveryInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RouteColors.blueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: RouteColors.blue),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              AppStrings.dOPDeliveringGuideContent.tr(),
              style: TextStyle(
                color: RouteColors.text,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveringOrderList extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;
  final List<DeliveryOrderEntity> orders;

  const DeliveringOrderList({
    super.key,
    required this.deliveryRoute,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    orders.sort((a, b) => a.sequenceOrder! - b.sequenceOrder!);

    if (orders.isEmpty) {
      return Center(child: Text(AppStrings.dOPNoOrdersInRouteContent.tr()));
    }

    final Map<String, String> uniqueOrderCodeSuffixMap =
        _getUniqueOrderSuffixes(orders);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        final status = order.status == DeliveryOrderStatus.delivered.value
            ? DeliveryOrderStatus.delivered
            : order.status == DeliveryOrderStatus.cancelled.value
            ? DeliveryOrderStatus.cancelled
            : order.status == DeliveryOrderStatus.rescheduled.value
            ? DeliveryOrderStatus.rescheduled
            : deliveryRoute.currentNeedDeliveringOrder?.id == order.id
            ? DeliveryOrderStatus.delivering
            : DeliveryOrderStatus.sorted;

        final time = order.status == DeliveryOrderStatus.delivered.value
            ? DateFormat('HH:mm').format(order.deliveredAt!.toLocal())
            : order.status == DeliveryOrderStatus.cancelled.value
            ? DateFormat('HH:mm').format(order.cancelledAt!.toLocal())
            : order.status == DeliveryOrderStatus.rescheduled.value
            ? DateFormat('HH:mm').format(order.rescheduledAt!.toLocal())
            : deliveryRoute.currentNeedDeliveringOrder?.id == order.id
            ? null
            : null;

        return DeliveringOrderItem(
          index: index,
          uniqueOrderCodeSuffix: uniqueOrderCodeSuffixMap[order.id]!,
          totalOrders: orders.length,
          sequenceOrder: order.sequenceOrder!,
          orderCode: order.orderCode,
          contactName: order.contactName,
          address: order.address,
          contactPhone: order.contactPhone,
          time: time,
          status: status,
          onTap: () {
            context.pushNamed(
              AppRouteNames.deliveryOrderDetail,
              pathParameters: {
                'id': order.deliveryRouteId,
                'deliveryOrderId': order.id,
              },
              extra: <String, Object>{
                'DeliveryRouteData': deliveryRoute,
                'DeliveryOrderData': order,
                'GetDeliveryRoutesCubitInDOP': context
                    .read<GetDeliveryRoutesCubit>(),
                'GetDeliveryRoutesUsecaseParamsInDOP':
                    GetDeliveryRoutesUsecaseParams(
                      id: deliveryRoute.id,
                      pageNumber: 1,
                      pageSize: 1,
                    ),
              },
            );
          },
        );
      },
    );
  }
}

class DeliveringOrderItem extends StatelessWidget {
  final int index;
  final int sequenceOrder;
  final int totalOrders;
  final String orderCode;
  final String contactName;
  final String address;
  final String contactPhone;
  final String? time;
  final DeliveryOrderStatus status;
  final VoidCallback? onTap;
  final String uniqueOrderCodeSuffix;

  const DeliveringOrderItem({
    super.key,
    required this.index,
    required this.sequenceOrder,
    required this.totalOrders,
    required this.orderCode,
    required this.contactName,
    required this.address,
    required this.contactPhone,
    required this.status,
    this.onTap,
    this.time,
    required this.uniqueOrderCodeSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Timeline line
        if (index != totalOrders - 1)
          Positioned(
            left: 20,
            top: 21,
            bottom: -21,
            child: Container(width: 2, color: const Color(0xFFE2E8F0)),
          ),

        Column(
          children: [
            if (index != 0) const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline node
                SizedBox(
                  width: 42,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildTimelineNode(theme),
                  ),
                ),

                const SizedBox(width: 4),

                // Order card
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.border),
                      ),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12),
                        splashColor: theme.primary.withValues(alpha: 0.08),
                        highlightColor: theme.primary.withValues(alpha: 0.04),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // =========================
                              // ORDER CODE + STATUS
                              // =========================
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: orderCode.substring(
                                              0,
                                              orderCode.length -
                                                  uniqueOrderCodeSuffix.length,
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primary,
                                            ),
                                          ),

                                          TextSpan(
                                            text: uniqueOrderCodeSuffix,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  _buildStatusBadge(theme),

                                  if (time != null) ...[
                                    const SizedBox(width: 8),

                                    Text(
                                      time!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF172554),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(width: 4),

                                  const Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: Color(0xFF172554),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 7),

                              // =========================
                              // CONTACT NAME + PHONE
                              // =========================
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 17,
                                    color: theme.iconColor,
                                  ),

                                  const SizedBox(width: 7),

                                  Expanded(
                                    child: Text(
                                      contactName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Icon(
                                    Icons.phone_outlined,
                                    size: 17,
                                    color: theme.iconColor,
                                  ),

                                  const SizedBox(width: 5),

                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      contactPhone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              // =========================
                              // ADDRESS
                              // =========================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 17,
                                    color: theme.iconColor,
                                  ),

                                  const SizedBox(width: 7),

                                  Expanded(
                                    child: Text(
                                      address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // =========================
                              // SUCCESS
                              // =========================
                              if (status == DeliveryOrderStatus.delivered)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      AppStrings.dOPDeliveredStatus.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ),

                              // =========================
                              // DELIVERING
                              // =========================
                              if (status == DeliveryOrderStatus.delivering)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      AppStrings.dOPNextDestinationTitle.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ),

                              // =========================
                              // RESCHEDULED
                              // =========================
                              if (status == DeliveryOrderStatus.rescheduled)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      AppStrings.dOPRescheduledStatus.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ),

                              // =========================
                              // CANCELLED
                              // =========================
                              if (status == DeliveryOrderStatus.cancelled)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      AppStrings.dOPCancelledStatus.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TIMELINE NODE
  // ============================================================

  Widget _buildTimelineNode(_DeliveryTheme theme) {
    switch (status) {
      case DeliveryOrderStatus.delivered:
        return _buildStatusNode(theme: theme, icon: Icons.check, iconSize: 17);

      case DeliveryOrderStatus.delivering:
        return _buildStatusNode(
          theme: theme,
          icon: Icons.navigation,
          iconSize: 15,
        );

      case DeliveryOrderStatus.sorted:
        return _buildStatusNode(
          theme: theme,
          icon: Icons.inventory_2_outlined,
          iconSize: 15,
        );

      case DeliveryOrderStatus.rescheduled:
        return _buildStatusNode(
          theme: theme,
          icon: Icons.schedule,
          iconSize: 15,
        );

      case DeliveryOrderStatus.cancelled:
        return _buildStatusNode(theme: theme, icon: Icons.close, iconSize: 17);

      default:
        return _buildStatusNode(
          theme: theme,
          icon: Icons.circle_outlined,
          iconSize: 15,
        );
    }
  }

  Widget _buildStatusNode({
    required _DeliveryTheme theme,
    required IconData icon,
    required double iconSize,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(_DeliveryTheme theme) {
    String text;

    switch (status) {
      case DeliveryOrderStatus.delivered:
        text = AppStrings.dOPSuccessStatus.tr();
        break;

      case DeliveryOrderStatus.delivering:
        text = AppStrings.dOPInDeliveryStatus.tr();
        break;

      case DeliveryOrderStatus.sorted:
        text = AppStrings.dOPNotDeliveredStatus.tr();
        break;

      case DeliveryOrderStatus.cancelled:
        text = AppStrings.dOPFailedStatus.tr();
        break;

      case DeliveryOrderStatus.rescheduled:
        text = AppStrings.dOPRescheduledStatus.tr();
        break;

      default:
        throw Exception(
          'Delivery order status does not match any valid status value.',
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.badgeBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.primary,
        ),
      ),
    );
  }

  // ============================================================
  // THEME
  // ============================================================

  _DeliveryTheme _getTheme() {
    switch (status) {
      // ----------------------------------------------------------
      // DELIVERED
      // ----------------------------------------------------------
      case DeliveryOrderStatus.delivered:
        return const _DeliveryTheme(
          primary: Color(0xFF16A34A),
          background: Colors.white,
          border: Color(0xFFE5E7EB),
          badgeBackground: Color(0xFFE8F7EE),
          iconColor: Color(0xFF16A34A),
        );

      // ----------------------------------------------------------
      // DELIVERING
      // ----------------------------------------------------------
      case DeliveryOrderStatus.delivering:
        return const _DeliveryTheme(
          primary: Color(0xFFF59E0B),
          background: Color(0xFFFFFBF2),
          border: Color(0xFFFCD77A),
          badgeBackground: Color(0xFFFFF1D6),
          iconColor: Color(0xFFD97706),
        );

      // ----------------------------------------------------------
      // SORTED
      // ----------------------------------------------------------
      case DeliveryOrderStatus.sorted:
        return const _DeliveryTheme(
          primary: Color(0xFF64748B),
          background: Colors.white,
          border: Color(0xFFE5E7EB),
          badgeBackground: Color(0xFFF1F5F9),
          iconColor: Color(0xFF64748B),
        );

      // ----------------------------------------------------------
      // RESCHEDULED
      // ----------------------------------------------------------
      case DeliveryOrderStatus.rescheduled:
        return const _DeliveryTheme(
          primary: Color(0xFF3B82F6),
          background: Colors.white,
          border: Color(0xFFE5E7EB),
          badgeBackground: Color(0xFFEFF6FF),
          iconColor: Color(0xFF3B82F6),
        );

      // ----------------------------------------------------------
      // CANCELLED
      // ----------------------------------------------------------
      case DeliveryOrderStatus.cancelled:
        return const _DeliveryTheme(
          primary: Color(0xFFEF4444),
          background: Color(0xFFFFF5F5),
          border: Color(0xFFFECACA),
          badgeBackground: Color(0xFFFEE2E2),
          iconColor: Color(0xFFEF4444),
        );

      default:
        throw Exception(
          'Delivery order status does not match any valid status value.',
        );
    }
  }
}

// ================================================================
// DELIVERY THEME
// ================================================================

class _DeliveryTheme {
  final Color primary;
  final Color background;
  final Color border;
  final Color badgeBackground;
  final Color iconColor;

  const _DeliveryTheme({
    required this.primary,
    required this.background,
    required this.border,
    required this.badgeBackground,
    required this.iconColor,
  });
}

// Completed
class CompletedView extends StatefulWidget {
  final DeliveryRouteEntity deliveryRoute;
  final BuildContext context;

  const CompletedView({
    super.key,
    required this.deliveryRoute,
    required this.context,
  });

  @override
  State<CompletedView> createState() => _CompletedViewState();
}

class _CompletedViewState extends State<CompletedView>
    with SingleTickerProviderStateMixin {
  late DeliveryRouteEntity _deliveryRoute;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _deliveryRoute = widget.deliveryRoute;
    widget.context.read<DeliveryOrderPageCubit>().tabChanged(
      tab: DeliveryOrderPageTab.completedOverview,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.context.read<SelectionCubit<String>>().closeSelectionMode();

        // Cập nhật trạng thái ở cấp page
        widget.context.read<DeliveryOrderPageCubit>().tabChanged(
          tab: _tabController.index == 0
              ? DeliveryOrderPageTab.completedOverview
              : _tabController.index == 1
              ? DeliveryOrderPageTab.completedDelivered
              : _tabController.index == 2
              ? DeliveryOrderPageTab.completedCancelled
              : DeliveryOrderPageTab.completedRescheduled,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant CompletedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.deliveryRoute != widget.deliveryRoute) {
        _deliveryRoute = widget.deliveryRoute;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveredOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.delivered.value)
        .toList();
    final cancelledOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.cancelled.value)
        .toList();
    final rescheduledOrders = _deliveryRoute.orders
        .where((order) => order.status == DeliveryOrderStatus.rescheduled.value)
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Thêm dòng này để cho phép trượt ngang các tab
            tabAlignment: TabAlignment
                .start, // Canh trái các tab khi trượt (Flutter 3.16+)
            indicatorColor: Colors.green,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.green,
            unselectedLabelColor: const Color(0xFF1E2440),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: [
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPOverviewTabTitle.tr(),
                  count: _deliveryRoute.totalOrders,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPDeliveredTabTitle.tr(),
                  count: deliveredOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPCancelledTabTitle.tr(),
                  count: cancelledOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: AppStrings.dOPRescheduledTabTitle.tr(),
                  count: rescheduledOrders.length,
                ),
              ),
            ],
          ),
        ),
        // 2. NỘI DUNG DANH SÁCH VUỐT ĐƯỢC
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CompletedSummary(deliveryRoute: _deliveryRoute),
              _OrderList(
                orders: deliveredOrders,
                deliveryRoute: _deliveryRoute,
              ),
              _OrderList(
                orders: cancelledOrders,
                deliveryRoute: _deliveryRoute,
              ),
              _OrderList(
                orders: rescheduledOrders,
                deliveryRoute: _deliveryRoute,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompletedSummary extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const CompletedSummary({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _CompletedBanner(deliveryRoute: deliveryRoute),
          RouteStatistics(route: deliveryRoute),

          // _OrderListPreview(orders: route.orders),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;
  const _CompletedBanner({required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: RouteColors.greenLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: RouteColors.green, size: 72),

          SizedBox(height: 12),

          Text(
            AppStrings.dOPCompletedRouteHeader.tr(),
            style: TextStyle(
              color: RouteColors.green,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6),

          Text(
            AppStrings.dOPDeliveredOrdersContent.tr(
              namedArgs: {
                'delivered': deliveryRoute.totalDeliveredOrders.toString(),
                'total': deliveryRoute.totalOrders.toString(),
              },
            ),
            style: TextStyle(
              color: RouteColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8),

          Text(
            AppStrings.dOPCompletedAtContent.tr(
              namedArgs: {
                'date': DateFormat(
                  'HH:mm, dd/MM/yyyy',
                ).format(deliveryRoute.updatedAt.toLocal()),
              },
            ),
            style: TextStyle(color: RouteColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class RouteStatistics extends StatelessWidget {
  final DeliveryRouteEntity route;

  const RouteStatistics({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RouteColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dOPRouteSummaryHeader.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: RouteColors.text,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatisticItem(
                  icon: Icons.route,
                  title: AppStrings.dOPTotalDistanceTitle.tr(),
                  value:
                      '${(route.totalDistance! / 1000).toStringAsFixed(2)} km',
                  subtitle: '',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.shopping_bag_outlined,
                  title: AppStrings.dOPTotalOrdersTitle.tr(),
                  value: '${route.totalOrders}',
                  subtitle: AppStrings.dOPOrderUnit.tr(),
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          Row(
            children: [
              Expanded(
                child: _StatisticItem(
                  icon: Icons.check_circle_outline,
                  title: AppStrings.dOPSuccessTitle.tr(),
                  value: route.totalDeliveredOrders.toString(),
                  subtitle:
                      '(${(route.totalDeliveredOrders / route.totalOrders * 100).toStringAsFixed(1)}%)',
                  color: RouteColors.green,
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.access_time,
                  title: AppStrings.dOPRescheduledTitle.tr(),
                  value: route.totalRescheduledOrders.toString(),
                  subtitle:
                      '(${(route.totalRescheduledOrders / route.totalOrders * 100).toStringAsFixed(1)}%)',
                  color: const Color(0xFFF59E0B),
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.cancel_outlined,
                  title: AppStrings.dOPFailedTitle.tr(),
                  value: route.totalCancelledOrders.toString(),
                  subtitle:
                      '(${(route.totalCancelledOrders / route.totalOrders * 100).toStringAsFixed(1)}%)',
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.color = RouteColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha((0.10 * 255).round()),
          ),
          child: Icon(icon, color: color, size: 22),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: RouteColors.secondaryText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: RouteColors.text,
                ),
              ),

              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: RouteColors.secondaryText,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum CheckOrderMethod { scanQrOrBarcode, manual }

enum DirectionToMapMethod { googleMap, smGoMap }

enum ConfirmSortedOrderMethod { scanQrOrBarcode, manual }

enum ConfirmResultDeliveringOrderMethod { scanQrOrBarcode, manual }

class _RouteActionBar extends StatefulWidget {
  final DeliveryRouteEntity route;
  final BuildContext context;

  const _RouteActionBar({
    super.key,
    required this.route,
    required this.context,
  });

  @override
  State<_RouteActionBar> createState() => __RouteActionBarState();
}

class __RouteActionBarState extends State<_RouteActionBar> {
  late DeliveryRouteEntity _deliveryRoute;
  CheckOrderMethod _checkOrderMethod = CheckOrderMethod.scanQrOrBarcode;
  DirectionToMapMethod _directionToMapMethod = DirectionToMapMethod.googleMap;
  ConfirmSortedOrderMethod _confirmSortedOrderMethod =
      ConfirmSortedOrderMethod.scanQrOrBarcode;
  ConfirmResultDeliveringOrderMethod _confirmResultDeliveringOrderMethod =
      ConfirmResultDeliveringOrderMethod.scanQrOrBarcode;

  @override
  void initState() {
    super.initState();
    _deliveryRoute = widget.route;
  }

  @override
  void didUpdateWidget(covariant _RouteActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.route != widget.route) {
        _deliveryRoute = widget.route;
      }
    });
  }

  void _changeCheckOrderMethod({required CheckOrderMethod value}) {
    setState(() {
      _checkOrderMethod = value;
    });
  }

  void _changeDirectionToMapMethod({required DirectionToMapMethod value}) {
    setState(() {
      _directionToMapMethod = value;
    });
  }

  void _changeConfirmSortedOrderMethod({
    required ConfirmSortedOrderMethod value,
  }) {
    setState(() {
      _confirmSortedOrderMethod = value;
    });
  }

  void _changeConfirmResultDeliveringOrderMethod({
    required ConfirmResultDeliveringOrderMethod value,
  }) {
    setState(() {
      _confirmResultDeliveringOrderMethod = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deliveryRoute.status == DeliveryRouteStatus.completed.value &&
        context.read<DeliveryOrderPageCubit>().state.selectedTab !=
            DeliveryOrderPageTab.completedRescheduled) {
      return SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: _buildAction(context: context),
        ),
      ),
    );
  }

  Widget _buildAction({required BuildContext context}) {
    final deliveryOrderPageCubit = context.read<DeliveryOrderPageCubit>();
    final selectionCubit = context.read<SelectionCubit<String>>();
    if (_deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return Row(
        children: [
          const SizedBox(width: 12),

          _OutlineButton(
            icon: Icons.add,
            label: AppStrings.dOPAddOrderActionLabel.tr(),
            onPressed: () {
              context.pushNamed(
                AppRouteNames.addDeliveryOrder,
                pathParameters: {'id': _deliveryRoute.id},
                extra: <String, Object>{
                  'DeliveryRouteData': _deliveryRoute,
                  'GetDeliveryRoutesCubitInDOP': context
                      .read<GetDeliveryRoutesCubit>(),
                  'GetDeliveryRoutesUsecaseParamsInDOP':
                      GetDeliveryRoutesUsecaseParams(
                        id: _deliveryRoute.id,
                        pageNumber: 1,
                        pageSize: 1,
                      ),
                },
              );
            },
          ),

          const SizedBox(width: 12),

          if (selectionCubit.state.isEnabled &&
              deliveryOrderPageCubit.state.selectedTab ==
                  DeliveryOrderPageTab.checked) ...[
            _OutlineButton(
              icon: Icons.checklist_rtl,
              label: AppStrings.dOPRecheckOrdersActionLabel.tr(),
              subtitle: AppStrings.dOPRecheckOrdersActionSubtitle.tr(),
              onPressed: () {
                AppDialogUtils.showCustomDialog(
                  primaryColor: AppColors.primary,
                  context: context,
                  title: AppStrings.dOPRecheckOrdersDialogTitle.tr(),
                  subtitle: AppStrings.dOPRecheckOrdersDialogContent.tr(
                    namedArgs: {
                      'quantity': selectionCubit.state.selectedItems.length
                          .toString(),
                    },
                  ),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<RecheckDeliveryOrdersCubit>().call(
                          deliveryRouteId: _deliveryRoute.id,
                          deliveryOrderIds: selectionCubit.state.selectedItems
                              .toList(),
                        );
                        context.pop();
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
          ],

          _OutlineButton(
            disabled:
                !(((_checkOrderMethod == CheckOrderMethod.manual &&
                            selectionCubit.state.isEnabled) ||
                        _checkOrderMethod ==
                            CheckOrderMethod.scanQrOrBarcode) &&
                    deliveryOrderPageCubit.state.selectedTab ==
                        DeliveryOrderPageTab.pending &&
                    !_deliveryRoute.isAllChecked),
            icon: Icons.touch_app_outlined,
            label: AppStrings.dOPConfirmOrdersActionLabel.tr(),
            subtitle: _checkOrderMethod == CheckOrderMethod.scanQrOrBarcode
                ? AppStrings.dOPCheckMethodQrOrBarcode.tr()
                : AppStrings.dOPCheckMethodManual.tr(),
            onPressed: () {
              if (_checkOrderMethod == CheckOrderMethod.scanQrOrBarcode) {
                _openOrderScanScreenToConfirmCheckedOrder(context: context);
              } else {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPConfirmOrdersDialogTitle.tr(),
                  subtitle: AppStrings.dOPConfirmOrdersDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<ConfirmDeliveryOrdersCubit>().call(
                          deliveryRouteId: _deliveryRoute.id,
                          deliveryOrderIds: selectionCubit.state.selectedItems
                              .toList(),
                        );
                        context.pop();
                      },
                    ),
                  ],
                );
              }
            },
            onLongPress: () => _showCheckOrderOptionMethod(context: context),
          ),
          const SizedBox(width: 12),

          _PrimaryButton(
            disabled: !_deliveryRoute.isAllChecked,
            icon: Icons.local_shipping_outlined,
            label: AppStrings.dOPSortGoodsActionLabel.tr(),
            subtitle: AppStrings.dOPSortGoodsActionSubtitle.tr(),
            onPressed: () {
              AppDialogUtils.showSuccess(
                context: context,
                title: AppStrings.dOPSortGoodsDialogTitle.tr(),
                subtitle: AppStrings.dOPSortGoodsDialogContent.tr(),
                actions: [
                  SmgoButton(
                    isOutlined: true,
                    text: AppStrings.dOPCancelButtonLabel.tr(),
                    primaryColor: AppColors.primary,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  SmgoButton(
                    primaryColor: AppColors.primary,
                    text: AppStrings.dOPConfirmButtonLabel.tr(),
                    onPressed: () {
                      context.read<TransitionRouteToSortingCubit>().call(
                        deliveryRouteId: _deliveryRoute.id,
                      );
                      context.pop();
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(width: 12),
        ],
      );
    } else if (_deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return Row(
        children: [
          const SizedBox(width: 12),

          _OutlineButton(
            icon: Icons.fact_check_outlined,
            label: AppStrings.dOPBackToCheckingActionLabel.tr(),
            onPressed: () {
              if (_deliveryRoute.totalSortedOrders > 0) {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPBackToCheckingDialogTitle.tr(),
                  subtitle: AppStrings.dOPBackToCheckingDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<TransitionRouteToPendingCubit>().call(
                          deliveryRouteId: _deliveryRoute.id,
                        );
                        context.pop();
                      },
                    ),
                  ],
                );
              } else {
                context.read<TransitionRouteToPendingCubit>().call(
                  deliveryRouteId: _deliveryRoute.id,
                );
              }
            },
          ),

          const SizedBox(width: 12),

          if (!_deliveryRoute.isAllOrdersRouted) ...[
            _PrimaryButton(
              icon: Icons.local_shipping_outlined,
              label: AppStrings.dOPFindOptimalRouteActionLabel.tr(),
              onPressed: () async {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPFindOptimalRouteDialogTitle.tr(),
                  subtitle: AppStrings.dOPFindOptimalRouteDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () async {
                        context.pop();
                        final position =
                            await AppLocationUtils.getCurrentPosition(context);
                        if (!context.mounted || position == null) return;
                        context.read<SortDeliveryOrdersCubit>().call(
                          deliveryRouteId: _deliveryRoute.id,
                          source: Point(
                            x: position.longitude,
                            y: position.latitude,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(width: 12),
          ],

          if (_deliveryRoute.isAllOrdersRouted &&
              !_deliveryRoute.isAllSorted) ...[
            _OutlineButton(
              disabled: _deliveryRoute.currentNeedSortOrder == null,
              icon: Icons.done,
              label: AppStrings.dOPConfirmSortedActionLabel.tr(),
              subtitle:
                  _confirmSortedOrderMethod ==
                      ConfirmSortedOrderMethod.scanQrOrBarcode
                  ? AppStrings.dOPConfirmSortedMethodQrOrBarcode.tr()
                  : AppStrings.dOPConfirmSortedMethodQuick.tr(),
              onPressed: () {
                if (_confirmSortedOrderMethod ==
                    ConfirmSortedOrderMethod.scanQrOrBarcode) {
                  _openOrderScanScreenToConfirmSortedOrder(context: context);
                } else {
                  AppDialogUtils.showSuccess(
                    context: context,
                    title: AppStrings.dOPConfirmSortedDialogTitle.tr(),
                    subtitle: AppStrings.dOPConfirmSortedDialogContent.tr(),
                    actions: [
                      SmgoButton(
                        isOutlined: true,
                        text: AppStrings.dOPCancelButtonLabel.tr(),
                        primaryColor: AppColors.primary,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      SmgoButton(
                        primaryColor: AppColors.primary,
                        text: AppStrings.dOPConfirmButtonLabel.tr(),
                        onPressed: () {
                          context.read<ConfirmSortedDeliveryOrdersCubit>().call(
                            deliveryRouteId: _deliveryRoute.id,
                            deliveryOrderIds: [
                              _deliveryRoute.currentNeedSortOrder!.id,
                            ],
                          );
                          context.pop();
                        },
                      ),
                    ],
                  );
                }
              },
              onLongPress: () =>
                  _showConfirmSortedOrderMethods(context: context),
            ),

            const SizedBox(width: 12),
          ],

          _PrimaryButton(
            disabled: !_deliveryRoute.isAllSorted,
            icon: Icons.play_arrow,
            label: AppStrings.dOPStartDeliveryActionLabel.tr(),
            subtitle: AppStrings.dOPStartDeliveryActionSubtitle.tr(),
            onPressed: () {
              AppDialogUtils.showSuccess(
                context: context,
                title: AppStrings.dOPStartDeliveryDialogTitle.tr(),
                subtitle: AppStrings.dOPStartDeliveryDialogContent.tr(),
                actions: [
                  SmgoButton(
                    isOutlined: true,
                    text: AppStrings.dOPCancelButtonLabel.tr(),
                    primaryColor: AppColors.primary,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  SmgoButton(
                    primaryColor: AppColors.primary,
                    text: AppStrings.dOPConfirmButtonLabel.tr(),
                    onPressed: () async {
                      context.read<TransitionRouteToDeliveringCubit>().call(
                        deliveryRouteId: _deliveryRoute.id,
                      );
                      context.pop();
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(width: 12),
        ],
      );
    } else if (_deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return Row(
        children: [
          const SizedBox(width: 12),

          if (_deliveryRoute.currentNeedDeliveringOrder != null) ...[
            _PrimaryButton(
              icon: Icons.navigation,
              label: AppStrings.dOPNavigateMapActionLabel.tr(),
              subtitle: _directionToMapMethod == DirectionToMapMethod.googleMap
                  ? AppStrings.dOPNavigationGoogleMap.tr()
                  : AppStrings.dOPNavigationSmgoMap.tr(),
              onPressed: () async {
                final googleMapDirectionsUri =
                    ExternalUrlUtil.getGoogleMapsDirectionsUri(
                      destinationLat:
                          _deliveryRoute.currentNeedDeliveringOrder!.location.y,
                      destinationLng:
                          _deliveryRoute.currentNeedDeliveringOrder!.location.x,
                    );
                if (await canLaunchUrl(googleMapDirectionsUri)) {
                  await launchUrl(googleMapDirectionsUri);
                }
              },
              onLongPress: () => _showDirectionToMapMethod(context: context),
            ),

            const SizedBox(width: 12),
          ],

          if (_deliveryRoute.currentNeedDeliveringOrder != null) ...[
            _OutlineButton(
              icon: Icons.phone_android_rounded,
              label: AppStrings.dOPContactActionLabel.tr(),
              subtitle: AppStrings.dOPContactActionSubtitle.tr(),
              onPressed: () => _showContactMethod(context: context),
            ),

            const SizedBox(width: 12),
          ],

          if (_deliveryRoute.currentNeedDeliveringOrder != null) ...[
            _OutlineButton(
              icon: Icons.task_alt_rounded,
              label: AppStrings.dOPConfirmDeliveryActionLabel.tr(),
              subtitle:
                  _confirmResultDeliveringOrderMethod ==
                      ConfirmResultDeliveringOrderMethod.scanQrOrBarcode
                  ? AppStrings.dOPConfirmDeliveryMethodQrOrBarcode.tr()
                  : AppStrings.dOPConfirmDeliveryMethodQuick.tr(),
              onPressed: () =>
                  _showConfirmDeliveryOrderMethod(context: context),
              onLongPress: () =>
                  _showConfirmResultDeliveringOrderMethods(context: context),
            ),

            const SizedBox(width: 12),
          ],

          if (_deliveryRoute.currentNeedDeliveringOrder == null)
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 24,
              child: _PrimaryButton(
                disabled: false,
                icon: Icons.check_circle_outline_rounded,
                label: AppStrings.dOPCompleteRouteActionLabel.tr(),
                subtitle: AppStrings.dOPCompleteRouteActionSubtitle.tr(),
                onPressed: () {
                  context.read<TransitionRouteToCompletedCubit>().call(
                    deliveryRouteId: _deliveryRoute.id,
                  );
                },
              ),
            )
          else
            _PrimaryButton(
              disabled: true,
              icon: Icons.check_circle_outline_rounded,
              label: AppStrings.dOPCompleteRouteActionLabel.tr(),
              subtitle: AppStrings.dOPCompleteRouteActionSubtitle.tr(),
              onPressed: () {},
            ),

          const SizedBox(width: 12),
        ],
      );
    } else if (_deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      if (deliveryOrderPageCubit.state.selectedTab ==
          DeliveryOrderPageTab.completedRescheduled) {
        return Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 24,
              child: _PrimaryButton(
                disabled: !selectionCubit.state.isEnabled,
                icon: Icons.navigation,
                label: AppStrings.dOPCreateNewRouteActionLabel.tr(),
                subtitle: AppStrings.dOPCreateNewRouteActionSubtitle.tr(),
                onPressed: () async {
                  context.read<CreateDeliveryRouteWithOrdersCubit>().call(
                    routeName: AppStrings.dOPRedeliveryRouteName.tr(
                      namedArgs: {'routeId': _deliveryRoute.id},
                    ),
                    orders: _deliveryRoute.orders
                        .where(
                          (order) => selectionCubit.state.selectedItems.any(
                            (selectedItem) => selectedItem == order.id,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }

  void _showContactMethod({required BuildContext context}) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.phone_android_rounded,
      title: AppStrings.dOPContactMethodTitle.tr(),
      subtitle: AppStrings.dOPContactMethodSubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Icon(
              Icons.phone,
              color: const ui.Color.fromRGBO(22, 163, 74, 1),
            ),
            title: AppStrings.dOPDirectCallTitle.tr(),
            subtitle: AppStrings.dOPDirectCallSubtitle.tr(),
            onTap: () async {
              final currentNeedDeliveringOrder =
                  _deliveryRoute.currentNeedDeliveringOrder;
              if (currentNeedDeliveringOrder != null) {
                final url = ExternalUrlUtil.getDialUrl(
                  currentNeedDeliveringOrder.contactPhone,
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              }
              if (!context.mounted) return;
              context.pop();
            },
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(
              Icons.sms,
              color: const ui.Color.fromRGBO(22, 163, 74, 1),
            ),
            title: AppStrings.dOPSmsContactTitle.tr(),
            subtitle: AppStrings.dOPSmsContactSubtitle.tr(),
            onTap: () async {
              final currentNeedDeliveringOrder =
                  _deliveryRoute.currentNeedDeliveringOrder;
              if (currentNeedDeliveringOrder != null) {
                final url = ExternalUrlUtil.getSmsUrl(
                  phoneNumber: currentNeedDeliveringOrder.contactPhone,
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              }
              if (!context.mounted) return;
              context.pop();
            },
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Image.asset(AppAssets.icZalo, width: 24),
            title: AppStrings.dOPZaloContactTitle.tr(),
            subtitle: AppStrings.dOPZaloContactSubtitle.tr(),
            onTap: () async {
              final currentNeedDeliveringOrder =
                  _deliveryRoute.currentNeedDeliveringOrder;
              if (currentNeedDeliveringOrder != null) {
                final url = ExternalUrlUtil.getZaloUrl(
                  currentNeedDeliveringOrder.contactPhone,
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              }
              if (!context.mounted) return;
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  void _openOrderScanScreenToConfirmSortedOrder({
    required BuildContext context,
  }) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();
    final parentContext = context;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return _deliveryRoute.currentNeedSortOrder?.orderCode == rawValue
                  ? _deliveryRoute.currentNeedSortOrder
                  : null;
            }
            return null;
          },
          itemBuilder: (context, order) {
            // ============================================================
            // QUÉT SAI / KHÔNG TÌM THẤY ĐƠN
            // ============================================================
            if (order == null ||
                order.id != _deliveryRoute.currentNeedSortOrder?.id) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Marker cảnh báo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.10 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppStrings.dOPWrongSortingOrderTitle.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.dOPWrongSortingOrderContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppStrings.dOPRescanButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ============================================================
            // QUÉT ĐÚNG ĐƠN
            // ============================================================
            return BlocProvider<ConfirmSortedDeliveryOrdersCubit>(
              create: (context) => di<ConfirmSortedDeliveryOrdersCubit>(),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ==================================================
                        // MARKER: ĐÃ LẤY ĐÚNG HÀNG
                        // ==================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              (0.08 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(
                                (0.25 * 255).round(),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.dOPCorrectOrderTitle.tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppStrings.dOPCorrectSortingOrderContent
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // THÔNG TIN ĐƠN HÀNG
                        // ==================================================
                        _buildInfoRow(
                          Icons.view_column,
                          AppStrings.dOPOrderCodeLabel.tr(),
                          order.orderCode,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          AppStrings.dODPOrderNameLabel.tr(),
                          order.orderName?.isNotEmpty == true
                              ? order.orderName!
                              : AppStrings.dOPNoOrderName.tr(),
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          AppStrings.dOPRecipientNameLabel.tr(),
                          order.contactName,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          AppStrings.dOPPhoneNumberLabel.tr(),
                          order.contactPhone,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          AppStrings.dOPDeliveryAddressLabel.tr(),
                          order.address,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          AppStrings.dOPOrderImageLabel.tr(),
                          order.orderMediaUrl ?? '',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // BOTTOM BUTTON
                // ========================================================
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child:
                      BlocConsumer<
                        ConfirmSortedDeliveryOrdersCubit,
                        ConfirmSortedDeliveryOrdersState
                      >(
                        listener: (context, state) {
                          if (state is ConfirmSortedDeliveryOrdersDone) {
                            getDeliveryRoutesCubitInParent.call(
                              params: GetDeliveryRoutesUsecaseParams(
                                pageNumber: 1,
                                pageSize: 1,
                                id: order.deliveryRouteId,
                              ),
                            );

                            context.pop();
                            context.pop();

                            AppDialogUtils.showSuccess(
                              context: parentContext,
                              title: AppStrings.dOPScanConfirmSuccessTitle.tr(),
                              subtitle: AppStrings.dOPScanConfirmSuccessContent
                                  .tr(
                                    namedArgs: {'orderCode': order.orderCode},
                                  ),
                            );
                          } else if (state
                              is ConfirmSortedDeliveryOrdersFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings.dOPScanConfirmFailedTitle.tr(),
                              subtitle: AppStrings.dOPScanConfirmFailedContent
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading =
                              state is ConfirmSortedDeliveryOrdersLoading;

                          return SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled: isLoading,
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.dOPRescanButtonLabel
                                                .tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled:
                                          isLoading ||
                                          order.status ==
                                              DeliveryOrderStatus.sorted.value,
                                      onPressed: () {
                                        context
                                            .read<
                                              ConfirmSortedDeliveryOrdersCubit
                                            >()
                                            .call(
                                              deliveryRouteId:
                                                  order.deliveryRouteId,
                                              deliveryOrderIds: [order.id],
                                            );
                                      },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.status ==
                                                          DeliveryOrderStatus
                                                              .sorted
                                                              .value
                                                      ? AppStrings
                                                            .dOPConfirmedLabel
                                                            .tr()
                                                      : AppStrings
                                                            .dOPUnconfirmedLabel
                                                            .tr(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            );
          },
          onComplete: (context, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }

  void _showConfirmDeliveryOrderMethod({required BuildContext context}) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.check_circle_outline_rounded,
      title: AppStrings.dOPConfirmDeliveryTitle.tr(),
      subtitle: AppStrings.dOPConfirmDeliverySubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Icon(Icons.check_circle, color: const Color(0xFF16A34A)),
            title: AppStrings.dOPDeliveredOptionTitle.tr(),
            subtitle: AppStrings.dOPDeliveredOptionSubtitle.tr(),
            onTap: () {
              if (_confirmResultDeliveringOrderMethod ==
                  ConfirmResultDeliveringOrderMethod.scanQrOrBarcode) {
                _openOrderScanScreenToConfirmDeliveredOrder(context: context);
                context.pop();
              } else {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPDeliveredDialogTitle.tr(),
                  subtitle: AppStrings.dOPDeliveredDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<ConfirmDeliveredOrderCubit>().call(
                          deliveryRouteId: _deliveryRoute
                              .currentNeedDeliveringOrder!
                              .deliveryRouteId,
                          deliveryOrderId:
                              _deliveryRoute.currentNeedDeliveringOrder!.id,
                        );
                        context.pop();
                        context.pop();
                      },
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(Icons.cancel, color: const Color(0xFFDC2626)),
            title: AppStrings.dOPCancelledOptionTitle.tr(),
            subtitle: AppStrings.dOPCancelledOptionSubtitle.tr(),
            onTap: () {
              if (_confirmResultDeliveringOrderMethod ==
                  ConfirmResultDeliveringOrderMethod.scanQrOrBarcode) {
                _openOrderScanScreenToConfirmCancelledOrder(context: context);
                context.pop();
              } else {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPCancelledDialogTitle.tr(),
                  subtitle: AppStrings.dOPCancelledDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<ConfirmCancelledOrderCubit>().call(
                          deliveryRouteId: _deliveryRoute
                              .currentNeedDeliveringOrder!
                              .deliveryRouteId,
                          deliveryOrderId:
                              _deliveryRoute.currentNeedDeliveringOrder!.id,
                        );
                        context.pop();
                        context.pop();
                      },
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(Icons.schedule, color: const Color(0xFF3B82F6)),
            title: AppStrings.dOPRescheduledOptionTitle.tr(),
            subtitle: AppStrings.dOPRescheduledOptionSubtitle.tr(),
            onTap: () {
              if (_confirmResultDeliveringOrderMethod ==
                  ConfirmResultDeliveringOrderMethod.scanQrOrBarcode) {
                _openOrderScanScreenToConfirmRescheduledOrder(context: context);
                context.pop();
              } else {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: AppStrings.dOPRescheduledDialogTitle.tr(),
                  subtitle: AppStrings.dOPRescheduledDialogContent.tr(),
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: AppStrings.dOPCancelButtonLabel.tr(),
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: AppStrings.dOPConfirmButtonLabel.tr(),
                      onPressed: () {
                        context.read<ConfirmRescheduledOrderCubit>().call(
                          deliveryRouteId: _deliveryRoute
                              .currentNeedDeliveringOrder!
                              .deliveryRouteId,
                          deliveryOrderId:
                              _deliveryRoute.currentNeedDeliveringOrder!.id,
                        );
                        context.pop();
                        context.pop();
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmSortedOrderMethods({required BuildContext context}) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.rule_folder_outlined,
      title: AppStrings.dOPSortingConfirmationMethodTitle.tr(),
      subtitle: AppStrings.dOPSortingConfirmationMethodSubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Icon(Icons.qr_code_scanner, size: 24, color: Colors.blue),
            title: AppStrings.dOPSortingQrGuideTitle.tr(),
            subtitle: AppStrings.dOPSortingQrGuideSubtitle.tr(),
            onTap: () {
              _changeConfirmSortedOrderMethod(
                value: ConfirmSortedOrderMethod.scanQrOrBarcode,
              );
              context.pop();
            },
            isChosen:
                _confirmSortedOrderMethod ==
                ConfirmSortedOrderMethod.scanQrOrBarcode,
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(Icons.flash_on, size: 24, color: Colors.orange),
            title: AppStrings.dOPQuickConfirmationTitle.tr(),
            subtitle: AppStrings.dOPQuickConfirmationSubtitle.tr(),
            onTap: () {
              _changeConfirmSortedOrderMethod(
                value: ConfirmSortedOrderMethod.manual,
              );
              context.pop();
            },
            isChosen:
                _confirmSortedOrderMethod == ConfirmSortedOrderMethod.manual,
          ),
        ],
      ),
    );
  }

  void _showConfirmResultDeliveringOrderMethods({
    required BuildContext context,
  }) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.local_shipping_outlined,
      title: AppStrings.dOPDeliveryConfirmationMethodTitle.tr(),
      subtitle: AppStrings.dOPDeliveryConfirmationMethodSubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Icon(Icons.qr_code_scanner, size: 24, color: Colors.blue),
            title: AppStrings.dOPDeliveryQrGuideTitle.tr(),
            subtitle: AppStrings.dOPDeliveryQrGuideSubtitle.tr(),
            onTap: () {
              _changeConfirmResultDeliveringOrderMethod(
                value: ConfirmResultDeliveringOrderMethod.scanQrOrBarcode,
              );
              context.pop();
            },
            isChosen:
                _confirmResultDeliveringOrderMethod ==
                ConfirmResultDeliveringOrderMethod.scanQrOrBarcode,
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(Icons.flash_on, size: 24, color: Colors.orange),
            title: AppStrings.dOPDeliveryQuickConfirmationTitle.tr(),
            subtitle: AppStrings.dOPDeliveryQuickConfirmationSubtitle.tr(),
            onTap: () {
              _changeConfirmResultDeliveringOrderMethod(
                value: ConfirmResultDeliveringOrderMethod.manual,
              );
              context.pop();
            },
            isChosen:
                _confirmResultDeliveringOrderMethod ==
                ConfirmResultDeliveringOrderMethod.manual,
          ),
        ],
      ),
    );
  }

  void _showDirectionToMapMethod({required BuildContext context}) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.navigation,
      title: AppStrings.dOPNavigationOptionTitle.tr(),
      subtitle: AppStrings.dOPNavigationOptionSubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Image.asset(AppAssets.icGoogleMaps, width: 24),
            title: AppStrings.dOPGoogleMapNavigationTitle.tr(),
            subtitle: AppStrings.dOPGoogleMapNavigationSubtitle.tr(),
            onTap: () {
              _changeDirectionToMapMethod(
                value: DirectionToMapMethod.googleMap,
              );
              context.pop();
            },
            isChosen: _directionToMapMethod == DirectionToMapMethod.googleMap,
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Image.asset(AppAssets.logo, width: 24),
            title: AppStrings.dOPSmgoMapNavigationTitle.tr(),
            subtitle: AppStrings.dOPSmgoMapNavigationSubtitle.tr(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.dOPSmgoMapDevelopingContent.tr()),
                ),
              );
              context.pop();
            },
            isChosen: _directionToMapMethod == DirectionToMapMethod.smGoMap,
          ),
        ],
      ),
    );
  }

  void _showCheckOrderOptionMethod({required BuildContext context}) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.fact_check_outlined,
      title: AppStrings.dOPCheckMethodSelectionTitle.tr(),
      subtitle: AppStrings.dOPCheckMethodSelectionSubtitle.tr(),
      content: Column(
        children: [
          OptionButton(
            icon: Icon(
              Icons.qr_code_scanner,
              color: _checkOrderMethod == CheckOrderMethod.scanQrOrBarcode
                  ? AppColors.primary
                  : Colors.black,
            ),
            title: AppStrings.dOPCheckQrMethodTitle.tr(),
            subtitle: AppStrings.dOPCheckQrMethodSubtitle.tr(),
            onTap: () {
              _changeCheckOrderMethod(value: CheckOrderMethod.scanQrOrBarcode);
              context.pop();
            },
            isChosen: _checkOrderMethod == CheckOrderMethod.scanQrOrBarcode,
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icon(
              Icons.checklist,
              color: _checkOrderMethod == CheckOrderMethod.manual
                  ? AppColors.primary
                  : Colors.black,
            ),
            title: AppStrings.dOPManualCheckMethodTitle.tr(),
            subtitle: AppStrings.dOPManualCheckMethodSubtitle.tr(),
            onTap: () {
              _changeCheckOrderMethod(value: CheckOrderMethod.manual);
              context.pop();
            },
            isChosen: _checkOrderMethod == CheckOrderMethod.manual,
          ),
        ],
      ),
    );
  }

  void _openOrderScanScreenToConfirmRescheduledOrder({
    required BuildContext context,
  }) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();
    final parentContext = context;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return _deliveryRoute.currentNeedDeliveringOrder?.orderCode ==
                      rawValue
                  ? _deliveryRoute.currentNeedDeliveringOrder
                  : null;
            }
            return null;
          },
          itemBuilder: (context, order) {
            // ============================================================
            // QUÉT SAI / KHÔNG TÌM THẤY ĐƠN
            // ============================================================
            if (order == null ||
                order.id != _deliveryRoute.currentNeedDeliveringOrder?.id) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Marker cảnh báo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.10 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderTitle.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppStrings.dOPRescanButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ============================================================
            // QUÉT ĐÚNG ĐƠN
            // ============================================================
            return BlocProvider<ConfirmRescheduledOrderCubit>(
              create: (context) => di<ConfirmRescheduledOrderCubit>(),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ==================================================
                        // MARKER: ĐÃ LẤY ĐÚNG HÀNG
                        // ==================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              (0.08 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(
                                (0.25 * 255).round(),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.dOPCorrectDeliveryOrderTitle
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppStrings.dOPCorrectDeliveryOrderContent
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // THÔNG TIN ĐƠN HÀNG
                        // ==================================================
                        _buildInfoRow(
                          Icons.view_column,
                          AppStrings.dOPOrderCodeLabel.tr(),
                          order.orderCode,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          AppStrings.dODPOrderNameLabel.tr(),
                          order.orderName?.isNotEmpty == true
                              ? order.orderName!
                              : AppStrings.dOPNoOrderName.tr(),
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          AppStrings.dOPRecipientNameLabel.tr(),
                          order.contactName,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          AppStrings.dOPPhoneNumberLabel.tr(),
                          order.contactPhone,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          AppStrings.dOPDeliveryAddressLabel.tr(),
                          order.address,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          AppStrings.dOPOrderImageLabel.tr(),
                          order.orderMediaUrl ?? '',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // BOTTOM BUTTON
                // ========================================================
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child:
                      BlocConsumer<
                        ConfirmRescheduledOrderCubit,
                        ConfirmRescheduledOrderState
                      >(
                        listener: (context, state) {
                          if (state is ConfirmRescheduledOrderDone) {
                            getDeliveryRoutesCubitInParent.call(
                              params: GetDeliveryRoutesUsecaseParams(
                                pageNumber: 1,
                                pageSize: 1,
                                id: order.deliveryRouteId,
                              ),
                            );

                            context.pop();
                            context.pop();

                            AppDialogUtils.showSuccess(
                              context: parentContext,
                              title: AppStrings
                                  .dOPConfirmRescheduledOrderSuccessDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmRescheduledOrderSuccessDialogSubtitle
                                  .tr(
                                    namedArgs: {'orderCode': order.orderCode},
                                  ),
                            );
                          } else if (state is ConfirmRescheduledOrderFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmRescheduledOrderFailedDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmRescheduledOrderFailedDialogSubtitle
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading =
                              state is ConfirmRescheduledOrderLoading;

                          return SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled: isLoading,
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.dOPRescanButtonLabel
                                                .tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled:
                                          isLoading ||
                                          order.status ==
                                              DeliveryOrderStatus
                                                  .rescheduled
                                                  .value,
                                      onPressed: () {
                                        context
                                            .read<
                                              ConfirmRescheduledOrderCubit
                                            >()
                                            .call(
                                              deliveryRouteId:
                                                  order.deliveryRouteId,
                                              deliveryOrderId: order.id,
                                            );
                                      },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.status ==
                                                          DeliveryOrderStatus
                                                              .rescheduled
                                                              .value
                                                      ? AppStrings
                                                            .dOPConfirmedLabel
                                                            .tr()
                                                      : AppStrings
                                                            .dOPUnconfirmedLabel
                                                            .tr(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            );
          },
          onComplete: (context, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }

  void _openOrderScanScreenToConfirmCancelledOrder({
    required BuildContext context,
  }) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return _deliveryRoute.currentNeedDeliveringOrder?.orderCode ==
                      rawValue
                  ? _deliveryRoute.currentNeedDeliveringOrder
                  : null;
            }
            return null;
          },
          itemBuilder: (context, order) {
            // ============================================================
            // QUÉT SAI / KHÔNG TÌM THẤY ĐƠN
            // ============================================================
            if (order == null ||
                order.id != _deliveryRoute.currentNeedDeliveringOrder?.id) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Marker cảnh báo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.10 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderTitle.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppStrings.dOPRescanButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ============================================================
            // QUÉT ĐÚNG ĐƠN
            // ============================================================
            return BlocProvider<ConfirmCancelledOrderCubit>(
              create: (context) => di<ConfirmCancelledOrderCubit>(),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ==================================================
                        // MARKER: ĐÃ LẤY ĐÚNG HÀNG
                        // ==================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              (0.08 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(
                                (0.25 * 255).round(),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.dOPCorrectOrderTitle.tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppStrings.dOPCorrectDeliveryOrderContent
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // THÔNG TIN ĐƠN HÀNG
                        // ==================================================
                        _buildInfoRow(
                          Icons.view_column,
                          AppStrings.dOPOrderCodeLabel.tr(),
                          order.orderCode,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          AppStrings.dODPOrderNameLabel.tr(),
                          order.orderName?.isNotEmpty == true
                              ? order.orderName!
                              : AppStrings.dOPNoOrderName.tr(),
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          AppStrings.dOPRecipientNameLabel.tr(),
                          order.contactName,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          AppStrings.dOPPhoneNumberLabel.tr(),
                          order.contactPhone,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          AppStrings.dOPDeliveryAddressLabel.tr(),
                          order.address,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          AppStrings.dOPOrderImageLabel.tr(),
                          order.orderMediaUrl ?? '',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // BOTTOM BUTTON
                // ========================================================
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child:
                      BlocConsumer<
                        ConfirmCancelledOrderCubit,
                        ConfirmCancelledOrderState
                      >(
                        listener: (context, state) {
                          if (state is ConfirmCancelledOrderDone) {
                            getDeliveryRoutesCubitInParent.call(
                              params: GetDeliveryRoutesUsecaseParams(
                                pageNumber: 1,
                                pageSize: 1,
                                id: order.deliveryRouteId,
                              ),
                            );

                            context.pop();
                            context.pop();

                            AppDialogUtils.showSuccess(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmCanceledOrderSuccessDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmCanceledOrderSuccessDialogSubtitle
                                  .tr(
                                    namedArgs: {'orderCode': order.orderCode},
                                  ),
                            );
                          } else if (state is ConfirmCancelledOrderFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmCanceledOrderFailedDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmCanceledOrderFailedDialogSubtitle
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading =
                              state is ConfirmCancelledOrderLoading;

                          return SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled: isLoading,
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.dOPRescanButtonLabel
                                                .tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled:
                                          isLoading ||
                                          order.status ==
                                              DeliveryOrderStatus
                                                  .cancelled
                                                  .value,
                                      onPressed: () {
                                        context
                                            .read<ConfirmCancelledOrderCubit>()
                                            .call(
                                              deliveryRouteId:
                                                  order.deliveryRouteId,
                                              deliveryOrderId: order.id,
                                            );
                                      },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.status ==
                                                          DeliveryOrderStatus
                                                              .cancelled
                                                              .value
                                                      ? AppStrings
                                                            .dOPConfirmedLabel
                                                            .tr()
                                                      : AppStrings
                                                            .dOPUnconfirmedLabel
                                                            .tr(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            );
          },
          onComplete: (context, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }

  void _openOrderScanScreenToConfirmDeliveredOrder({
    required BuildContext context,
  }) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();
    final parentContext = context;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return _deliveryRoute.currentNeedDeliveringOrder?.orderCode ==
                      rawValue
                  ? _deliveryRoute.currentNeedDeliveringOrder
                  : null;
            }
            return null;
          },
          itemBuilder: (context, order) {
            // ============================================================
            // QUÉT SAI / KHÔNG TÌM THẤY ĐƠN
            // ============================================================
            if (order == null ||
                order.id != _deliveryRoute.currentNeedDeliveringOrder?.id) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Marker cảnh báo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.10 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderTitle.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.dOPWrongDeliveryOrderContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppStrings.dOPRescanButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ============================================================
            // QUÉT ĐÚNG ĐƠN
            // ============================================================
            return BlocProvider<ConfirmDeliveredOrderCubit>(
              create: (context) => di<ConfirmDeliveredOrderCubit>(),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ==================================================
                        // MARKER: ĐÃ LẤY ĐÚNG HÀNG
                        // ==================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              (0.08 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(
                                (0.25 * 255).round(),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.dOPCorrectOrderTitle.tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppStrings.dOPCorrectDeliveryOrderContent
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // THÔNG TIN ĐƠN HÀNG
                        // ==================================================
                        _buildInfoRow(
                          Icons.view_column,
                          AppStrings.dOPOrderCodeLabel.tr(),
                          order.orderCode,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          AppStrings.dODPOrderNameLabel.tr(),
                          order.orderName?.isNotEmpty == true
                              ? order.orderName!
                              : AppStrings.dOPNoOrderName.tr(),
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          AppStrings.dOPRecipientNameLabel.tr(),
                          order.contactName,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          AppStrings.dOPPhoneNumberLabel.tr(),
                          order.contactPhone,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          AppStrings.dOPDeliveryAddressLabel.tr(),
                          order.address,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          AppStrings.dOPOrderImageLabel.tr(),
                          order.orderMediaUrl ?? '',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // BOTTOM BUTTON
                // ========================================================
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child:
                      BlocConsumer<
                        ConfirmDeliveredOrderCubit,
                        ConfirmDeliveredOrderState
                      >(
                        listener: (context, state) {
                          if (state is ConfirmDeliveredOrderDone) {
                            getDeliveryRoutesCubitInParent.call(
                              params: GetDeliveryRoutesUsecaseParams(
                                pageNumber: 1,
                                pageSize: 1,
                                id: order.deliveryRouteId,
                              ),
                            );

                            context.pop();
                            context.pop();

                            AppDialogUtils.showSuccess(
                              context: parentContext,
                              title: AppStrings
                                  .dOPConfirmDeliveredOrderSuccessDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmDeliveredOrderSuccessDialogSubtitle
                                  .tr(
                                    namedArgs: {'orderCode': order.orderCode},
                                  ),
                            );
                          } else if (state is ConfirmDeliveredOrderFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmDeliveredOrderFailedDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmDeliveredOrderFailedDialogSubtitle
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading =
                              state is ConfirmDeliveredOrderLoading;

                          return SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled: isLoading,
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.dOPRescanButtonLabel
                                                .tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: SmgoButton(
                                      primaryColor: AppColors.primary,
                                      isDisabled:
                                          isLoading ||
                                          order.status ==
                                              DeliveryOrderStatus
                                                  .delivered
                                                  .value,
                                      onPressed: () {
                                        context
                                            .read<ConfirmDeliveredOrderCubit>()
                                            .call(
                                              deliveryRouteId:
                                                  order.deliveryRouteId,
                                              deliveryOrderId: order.id,
                                            );
                                      },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.status ==
                                                          DeliveryOrderStatus
                                                              .delivered
                                                              .value
                                                      ? AppStrings
                                                            .dOPConfirmedLabel
                                                            .tr()
                                                      : AppStrings
                                                            .dOPUnconfirmedLabel
                                                            .tr(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            );
          },
          onComplete: (context, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }

  void _openOrderScanScreenToConfirmCheckedOrder({
    required BuildContext context,
  }) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.dOPScanOrderInformationTitle.tr(),
          onHandleScan: (rawValue) async {
            if (rawValue.isNotEmpty) {
              return _deliveryRoute.orders
                  .where((order) => order.orderCode == rawValue)
                  .firstOrNull;
            }
            return null;
          },
          itemBuilder: (context, order) {
            if (order == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.1 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.dOPOrderNotFoundTitle.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.dOPOrderNotFoundContent.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006837),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.dOPScanAnotherCodeButtonLabel.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return BlocProvider<ConfirmDeliveryOrdersCubit>(
              create: (context) => di<ConfirmDeliveryOrdersCubit>(),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.view_column,
                          AppStrings.dOPOrderCodeLabel.tr(),
                          order.orderCode,
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          AppStrings.dODPOrderNameLabel.tr(),
                          order.orderName?.isNotEmpty == true
                              ? order.orderName!
                              : AppStrings.dOPNoOrderName.tr(),
                          showCopy: true,
                          context: context,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          AppStrings.dOPRecipientNameLabel.tr(),
                          order.contactName,
                          showCopy: true,
                          context: context,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          AppStrings.dOPPhoneNumberLabel.tr(),
                          order.contactPhone,
                          showCopy: true,
                          context: context,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          AppStrings.dOPDeliveryAddressLabel.tr(),
                          order.address,
                          showCopy: true,
                          context: context,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          AppStrings.dOPOrderImageLabel.tr(),
                          order.orderMediaUrl ?? '',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          (0.4 * 255).round(),
                        ), // Màu xanh lá đổ bóng
                        blurRadius: 4, // Độ loè của bóng
                      ),
                    ],
                  ),
                  child:
                      BlocConsumer<
                        ConfirmDeliveryOrdersCubit,
                        ConfirmDeliveryOrdersState
                      >(
                        listener: (context, state) {
                          if (state is ConfirmDeliveryOrdersDone) {
                            getDeliveryRoutesCubitInParent.call(
                              params: GetDeliveryRoutesUsecaseParams(
                                pageNumber: 1,
                                pageSize: 1,
                                id: order.deliveryRouteId,
                              ),
                            );
                            context.pop();
                            AppDialogUtils.showSuccess(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmCheckedOrderSuccessDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmCheckedOrderSuccessDialogSubtitle
                                  .tr(
                                    namedArgs: {'orderCode': order.orderCode},
                                  ),
                            );
                          } else if (state is ConfirmDeliveryOrdersFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings
                                  .dOPConfirmCheckedOrderFailedDialogTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .dOPConfirmCheckedOrderFailedDialogSubtitle
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SmgoButton(
                                  primaryColor: AppColors.primary,
                                  isDisabled:
                                      state is ConfirmDeliveryOrdersLoading,
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        AppStrings.dOPRescanButtonLabel.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SmgoButton(
                                  primaryColor: AppColors.primary,
                                  isDisabled:
                                      state is ConfirmDeliveryOrdersLoading ||
                                      order.status ==
                                          DeliveryOrderStatus.checked.value,
                                  onPressed: () {
                                    context
                                        .read<ConfirmDeliveryOrdersCubit>()
                                        .call(
                                          deliveryRouteId:
                                              order.deliveryRouteId,
                                          deliveryOrderIds: [order.id],
                                        );
                                  },
                                  child: state is ConfirmDeliveryOrdersLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              order.status ==
                                                      DeliveryOrderStatus
                                                          .checked
                                                          .value
                                                  ? AppStrings.dOPConfirmedLabel
                                                        .tr()
                                                  : AppStrings
                                                        .dOPUnconfirmedLabel
                                                        .tr(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            );
          },
          onComplete: (context, data) {
            AppAudioUtils.playAndDisposeAudio(AppAssets.audioBeep);
          },
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool disabled; // Thuộc tính quyết định trạng thái disable

  const _PrimaryButton({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onPressed,
    this.onLongPress,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF0F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFA7ABB9)),
            const SizedBox(width: 8),
            _buildTextContent(
              labelColor: const Color(0xFF9297A8),
              subtitleColor: const Color(0xFFA7ABB9),
            ),
          ],
        ),
      );
    }

    // Dùng chung OutlinedButton (hoặc TextButton) với style filled để triệt tiêu hoàn toàn độ lệch 1px của Material/InkWell
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        backgroundColor: RouteColors.green,
        foregroundColor: Colors.white,
        side: BorderSide.none,
        minimumSize: const Size(0, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          _buildTextContent(
            labelColor: Colors.white,
            subtitleColor: Colors.white70,
          ),
        ],
      ),
    );
  }

  // Hàm phụ trợ để tránh lặp lại phần hiển thị Text và Column
  Widget _buildTextContent({
    required Color labelColor,
    required Color subtitleColor,
  }) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: subtitleColor),
          ),
        ],
      );
    }

    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: labelColor,
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool disabled; // Thuộc tính quyết định trạng thái disable

  const _OutlineButton({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onPressed,
    this.onLongPress,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF0F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(0xFFA7ABB9)),
            const SizedBox(width: 8),
            _buildTextContent(
              labelColor: const Color(0xFF9297A8),
              subtitleColor: const Color(0xFFA7ABB9),
            ),
          ],
        ),
      );
    }

    // Ngược lại, trả về OutlinedButton
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        foregroundColor: RouteColors.green,
        side: const BorderSide(color: RouteColors.green),
        minimumSize: const Size(0, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RouteColors.green),
          const SizedBox(width: 8),
          _buildTextContent(
            labelColor: RouteColors.green, // Hoặc màu mặc định của text
            subtitleColor: RouteColors.green.withAlpha((0.8 * 255).round()),
          ),
        ],
      ),
    );
  }

  // Hàm phụ trợ để tránh lặp lại phần hiển thị Text và Column
  Widget _buildTextContent({
    required Color labelColor,
    required Color subtitleColor,
  }) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: subtitleColor),
          ),
        ],
      );
    }

    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14, color: labelColor),
    );
  }
}

class _CustomerBadge extends StatelessWidget {
  final bool familiar;

  const _CustomerBadge({required this.familiar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: familiar ? RouteColors.greenLight : RouteColors.blueLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        familiar
            ? AppStrings.dOPFamiliarCustomerLabel.tr()
            : AppStrings.dOPNewCustomerLabel.tr(),
        style: TextStyle(
          color: familiar ? RouteColors.green : RouteColors.blue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onPressed,
    );
  }
}

class RefreshOnlyScrollPhysics extends ScrollPhysics {
  const RefreshOnlyScrollPhysics({super.parent});

  @override
  RefreshOnlyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshOnlyScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value != position.pixels) {
      return value - position.pixels;
    }
    return 0;
  }
}

Map<String, String> _getUniqueOrderSuffixes(List<DeliveryOrderEntity> orders) {
  final result = <String, String>{};

  for (final order in orders) {
    final code = order.orderCode;

    for (int length = 1; length <= code.length; length++) {
      final suffix = code.substring(code.length - length);

      final isUnique = orders.every((other) {
        if (other.id == order.id) return true;

        final otherCode = other.orderCode;

        if (otherCode.length < length) return true;

        return otherCode.substring(otherCode.length - length) != suffix;
      });

      if (isUnique) {
        result[order.id] = suffix;
        break;
      }
    }
  }
  return result;
}

// Helper
Widget _buildInfoRow(
  IconData icon,
  String label,
  String value, {
  bool showCopy = false,
  required BuildContext context,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: const Color(0xFF006837)),
      const SizedBox(width: 12),
      SizedBox(
        width: 100,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (showCopy)
        IconButton(
          onPressed: () {
            _copyToClipboard(text: value, context: context);
          },
          icon: Icon(Icons.copy, size: 18, color: Color(0xFF006837)),
        ),
    ],
  );
}

void _copyToClipboard({
  required BuildContext context,
  required String text,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppStrings.dOPCopiedToClipboardContent.tr()),
      duration: Duration(seconds: 2),
    ),
  );
}

// Helper Widget dựng phần hiển thị ảnh đơn hàng lớn ở dưới cùng
Widget _buildImageRow(String label, String imageUrl) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.image_outlined, size: 20, color: Color(0xFF006837)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 120,
          width: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: Text(
                AppStrings.dOPNoImageContent.tr(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
