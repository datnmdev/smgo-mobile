import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_state.dart';
import 'package:shipgo/features/delivery_route/presentation/widgets/option_button.dart';
import 'package:shipgo/shared/presentation/bloc/selection/selection_cubit.dart';
import 'package:shipgo/shared/presentation/bloc/selection/selection_state.dart';
import 'package:shipgo/shared/utils/app_audio_utils.dart';
import 'package:shipgo/shared/utils/app_dialog_utils.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_generic_scan_screen.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_button.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_checkbox.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_loading_screen.dart';

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
        extra['GetDeliveryRoutesCubitInDRDP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDRDP =
        extra['GetDeliveryRoutesUsecaseParamsInDRDP']
            as GetDeliveryRoutesUsecaseParams;

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
      ],
      child: BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
        builder: (_, _) => BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
          listener: (_, state) {
            if (state is GetDeliveryRoutesDone) {
              if (state.routes.isNotEmpty) {
                setState(() {
                  deliveryRoute = state.routes.first;
                });
              }
              getDeliveryRoutesCubitInDRDP.call(
                params: getDeliveryRoutesUsecaseParamsInDRDP,
              );
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
                              child: _buildSelectionHeader(context: context),
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
                    context.read<SelectionCubit<String>>().closeSelectionMode();
                    AppDialogUtils.showSuccess(
                      context: context,
                      title: 'Yêu cầu kiểm tra lại đơn hàng thành công!',
                      subtitle:
                          'Các đơn hàng mà bạn đã yêu cầu đã được đưa vào danh sách đơn hàng chờ kiểm tra.',
                    );
                  } else if (state is RecheckDeliveryOrdersFailed) {
                    AppDialogUtils.showError(
                      context: context,
                      title: 'Yêu cầu kiểm tra lại đơn hàng thất bại!',
                      subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại.',
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
                  final selectionCubit = context.read<SelectionCubit<String>>();
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
                      title: 'Xác nhận đơn hàng thành công!',
                      subtitle:
                          '${selectionCubit.state.selectedItems.length} đơn hàng đã chọn đã được xác nhận thành công.',
                    );
                    selectionCubit.closeSelectionMode();
                  } else if (state is ConfirmDeliveryOrdersFailed) {
                    AppDialogUtils.showError(
                      context: context,
                      title: 'Xác nhận đơn hàng thất bại!',
                      subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại.',
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
                  }
                },
                builder: (context, state) => SmgoLoadingScreen(
                  isLoading: state is TransitionRouteToPendingLoading,
                ),
              ),

              BlocConsumer<SortDeliveryOrdersCubit, SortDeliveryOrdersState>(
                listener: (context, state) {
                  if (state is SortDeliveryOrdersDone) {
                    context.read<GetDeliveryRoutesCubit>().call(
                      params: GetDeliveryRoutesUsecaseParams(
                        pageNumber: 1,
                        pageSize: 1,
                        id: deliveryRoute.id,
                      ),
                    );
                  }
                },
                builder: (context, state) => SmgoLoadingScreen(
                  isLoading: state is SortDeliveryOrdersLoading,
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
    final selectionCubit = context.watch<SelectionCubit<String>>();
    final getDeliveryRoutesCubit = context.watch<GetDeliveryRoutesCubit>();

    final isAllSelectedInThisTab =
        deliveryRoute.orders.isNotEmpty &&
        deliveryRoute.orders.every(
          (e) => selectionCubit.state.selectedItems.contains(e.id),
        );

    if (selectionCubit.state.isEnabled &&
        getDeliveryRoutesCubit.state is! GetDeliveryRoutesLoading &&
        getDeliveryRoutesCubit.state is! GetDeliveryRoutesFailed &&
        deliveryRoute.orders.isNotEmpty) {
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
                      currentItems: deliveryRoute.orders
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
      return CompletedView(deliveryRoute: deliveryRoute);
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
              if (state.isEnabled)
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
                                          title: 'Xoá đơn hàng thành công!',
                                          subtitle:
                                              '${selectionCubit.state.selectedItems.length} đơn hàng đã bị xoá',
                                        );

                                        selectionCubit.closeSelectionMode();
                                      } else if (state
                                          is DeleteDeliveryOrdersFailed) {
                                        parentContext.pop();
                                        AppDialogUtils.showError(
                                          context: parentContext,
                                          title: 'Xoá đơn hàng thất bại!',
                                          subtitle:
                                              'Đã có lỗi xảy ra. Vui lòng thử lại',
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tạo lúc ${DateFormat('dd/MM/yyyy • HH:mm').format(deliveryRoute.createdAt)}',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 22),
                  ],
                ),

              const SizedBox(height: 20),

              const _SearchBox(),

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
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: RouteColors.text, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm đơn hàng...',
        hintStyle: const TextStyle(color: Color(0xFF9AA0B3), fontSize: 16),
        prefixIcon: const Icon(Icons.search, size: 28, color: RouteColors.text),
        suffixIcon: IconButton(
          onPressed: () {
            // TODO: scan QR
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
}

// Summary
class RouteSummary extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteSummary({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final familarCount = deliveryRoute.orders
        .where((order) => order.appliedLocationId != null)
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
              title: 'Tổng số đơn',
              value: '${deliveryRoute.totalOrders}',
              subtitle: 'đơn',
            ),
          ),

          _divider(),

          Expanded(child: _buildProgressSummary()),

          _divider(),

          Expanded(
            child: _SummaryItem(
              title: 'Khách quen',
              value: '$familarCount',
              subtitle:
                  'đơn (${deliveryRoute.totalOrders > 0 ? ((familarCount / deliveryRoute.totalOrders) * 100).round() : 0}%)',
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
        title: 'Tiến độ',
        progress: deliveryRoute.checkProgress,
        value: '${(deliveryRoute.checkProgress * 100).round()}%',
        subtitle:
            '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders}',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return _ProgressSummaryItem(
        title: 'Tiến độ',
        progress: deliveryRoute.sortingProgress,
        value: '${(deliveryRoute.sortingProgress * 100).round()}%',
        subtitle: deliveryRoute.isAllSorted ? 'Đã sắp xếp' : 'Chưa sắp xếp',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return _ProgressSummaryItem(
        title: 'Tiến độ',
        progress: deliveryRoute.deliveryProgress,
        value: '${(deliveryRoute.deliveryProgress * 100).round()}%',
        subtitle:
            '${deliveryRoute.totalDeliveredOrders + deliveryRoute.totalCancelledOrders + deliveryRoute.totalRescheduledOrders}/${deliveryRoute.totalOrders} đơn',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      // return _SummaryItem(
      //   title: 'Đã giao',
      //   value: '${deliveryRoute.tota}',
      //   subtitle: 'đơn',
      // );
      return _ProgressSummaryItem(
        title: 'Tiến độ',
        progress: 1,
        value: '100%',
        subtitle: '${deliveryRoute.totalOrders} đơn',
      );
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }

  Widget _buildStatusSummary() {
    if (deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return const _StatusSummaryItem(
        icon: Icons.check_circle_outline,
        color: RouteColors.green,
        text: 'Kiểm tra hàng',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.sorting.value) {
      return const _StatusSummaryItem(
        icon: Icons.access_time,
        color: RouteColors.blue,
        text: 'Sắp xếp',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return const _StatusSummaryItem(
        icon: Icons.access_time,
        color: RouteColors.blue,
        text: 'Đang giao hàng',
      );
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return const _StatusSummaryItem(
        icon: Icons.check_circle_outline,
        color: RouteColors.green,
        text: 'Hoàn thành',
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
        const Text(
          'Trạng thái',
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
              title: 'Kiểm tra đơn hàng',
              subtitle:
                  '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders} đơn',
              completed: currentStep > 1,
              active: currentStep == 1,
            ),

            _StepConnector(completed: currentStep > 2),

            _StepItem(
              step: 2,
              title: 'Sắp xếp hàng hoá',
              subtitle: _sortingSubtitle,
              completed: currentStep > 2,
              active: currentStep == 2,
            ),

            _StepConnector(completed: currentStep > 3),

            _StepItem(
              step: 3,
              title: 'Giao hàng',
              subtitle: _deliverySubtitle,
              completed: currentStep > 3,
              active: currentStep == 3,
            ),

            _StepConnector(completed: currentStep >= 4),

            _StepItem(
              step: 4,
              title: 'Hoàn thành',
              subtitle: deliveryRoute.isCompleted ? 'Hoàn tất' : null,
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

  String get _sortingSubtitle {
    if (deliveryRoute.isAllSorted) {
      return 'Đã sắp xếp';
    }

    if (deliveryRoute.totalSortedOrders == 0) {
      return 'Chưa sắp xếp';
    }

    return '${deliveryRoute.totalSortedOrders}/${deliveryRoute.totalOrders} đơn';
  }

  String? get _deliverySubtitle {
    if (deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return 'Đang giao';
    } else if (deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return '${deliveryRoute.totalOrders} đơn';
    } else {
      return null;
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
                  title: 'Chờ kiểm tra',
                  count: pendingOrders.length,
                ),
              ),
              Tab(
                child: _TabBadge(
                  title: 'Đã kiểm tra',
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
      return const Center(child: Text('Không có đơn hàng nào'));
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
            if (!selectionCubit.state.isEnabled) {
              selectionCubit.toggleSelection(item: orders[index].id);
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
    if (_deliveryRoute.isAllSorted) {
      sortedOrders.sort((a, b) => b.sequenceOrder! - a.sequenceOrder!);
    }
    return Column(
      children: [
        const _SortingGuide(),
        TotalDistanceCard(
          distanceText:
              '${_deliveryRoute.totalSortedOrders == _deliveryRoute.totalOrders ? '28.6' : '----'} km',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _deliveryRoute.orders.length,
            itemBuilder: (context, index) =>
                SortingOrderCard(order: sortedOrders[index]),
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
                    const Text(
                      'Tổng quãng đường dự kiến',
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

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn sắp xếp hàng hoá',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: RouteColors.text,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Số thứ tự càng lớn là đơn hàng giao sau cùng.\n'
                  'Vui lòng xếp hàng hoá từ dưới lên trên trong thùng '
                  'để đảm bảo giao đúng thứ tự.',
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            SmgoCheckbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              primaryColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
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
                                    Text(
                                      order.orderCode,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: RouteColors.text,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _CustomerBadge(
                                      familiar: order.appliedLocationId != null,
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
                                      : 'Không có tên đơn hàng',
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

class SortingOrderCard extends StatelessWidget {
  final DeliveryOrderEntity order;

  const SortingOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RouteColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RouteColors.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${order.sequenceOrder ?? '-'}',
              style: const TextStyle(
                color: RouteColors.green,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(child: OrderCardContent(order: order)),

          const Icon(Icons.chevron_right, color: RouteColors.text),
        ],
      ),
    );
  }
}

class OrderCardContent extends StatelessWidget {
  final DeliveryOrderEntity order;

  const OrderCardContent({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              order.orderCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: RouteColors.text,
              ),
            ),

            const SizedBox(width: 8),

            _CustomerBadge(familiar: order.appliedLocationId != null),
          ],
        ),

        const SizedBox(height: 6),

        _InfoRow(icon: Icons.person_outline, text: order.contactName),

        _InfoRow(
          icon: Icons.shopping_bag_outlined,
          text: order.orderName ?? '',
        ),

        _InfoRow(icon: Icons.location_on_outlined, text: order.address),
      ],
    );
  }
}

// Delevering
class DeliveringView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const DeliveringView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DeliveryTabs(),

        const _DeliveryInfoBanner(),

        ...deliveryRoute.orders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;

          return DeliveryTimelineOrderCard(
            index: index + 1,
            order: order,
            isCurrent: order.status == DeliveryOrderStatus.delivering,
          );
        }),
      ],
    );
  }
}

class _DeliveryTabs extends StatelessWidget {
  const _DeliveryTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _TabItem(title: 'Danh sách giao hàng', active: true)),
          Expanded(child: _TabItem(title: 'Thông tin lộ trình')),
          Expanded(child: _TabItem(title: 'Thống kê')),
          Expanded(child: _TabItem(title: 'Ghi chú')),
        ],
      ),
    );
  }
}

class _DeliveryInfoBanner extends StatelessWidget {
  const _DeliveryInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RouteColors.blueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: RouteColors.blue),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Bạn đang trên đường giao hàng. '
              'Hãy giao theo đúng thứ tự để tối ưu thời gian.',
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

class DeliveryTimelineOrderCard extends StatelessWidget {
  final int index;
  final DeliveryOrderEntity order;
  final bool isCurrent;

  const DeliveryTimelineOrderCard({
    super.key,
    required this.index,
    required this.order,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == DeliveryOrderStatus.delivered;

    final cardColor = isCurrent
        ? RouteColors.orangeLight
        : isDelivered
        ? RouteColors.greenLight
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 45,
            child: Column(
              children: [
                _TimelineCircle(
                  index: index,
                  delivered: isDelivered,
                  current: isCurrent,
                ),

                if (!isCurrent)
                  Container(
                    width: 2,
                    height: 75,
                    color: const Color(0xFFE4E7ED),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFFFD166)
                      : RouteColors.border,
                ),
              ),
              child: OrderCardContent(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final int index;
  final bool delivered;
  final bool current;

  const _TimelineCircle({
    required this.index,
    required this.delivered,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    if (delivered) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RouteColors.green,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    }

    if (current) {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RouteColors.orange,
        ),
        child: const Icon(Icons.navigation, color: Colors.white, size: 20),
      );
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F2F5),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: RouteColors.text,
        ),
      ),
    );
  }
}

// Completed
class CompletedView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const CompletedView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CompletedTabs(),

        const _CompletedBanner(),

        RouteStatistics(route: deliveryRoute),

        // _OrderListPreview(orders: route.orders),
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

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
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: RouteColors.green, size: 72),

          SizedBox(height: 12),

          Text(
            'LỘ TRÌNH ĐÃ HOÀN THÀNH',
            style: TextStyle(
              color: RouteColors.green,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6),

          Text(
            '15/15 đơn giao thành công',
            style: TextStyle(
              color: RouteColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Hoàn thành lúc 11:42, 20/05/2024',
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
          const Text(
            'TỔNG KẾT LỘ TRÌNH',
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
                  icon: Icons.access_time,
                  title: 'Thời gian',
                  value: '3h 12p',
                  subtitle: '08:30 – 11:42',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.route,
                  title: 'Quãng đường',
                  value: '12.8 km',
                  subtitle: '',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Tổng số đơn',
                  value: '${route.totalOrders}',
                  subtitle: 'đơn',
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
                  title: 'Thành công',
                  value: '${route.totalDeliveredOrders}',
                  subtitle: '(100%)',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.access_time,
                  title: 'Giao sau',
                  value: '0',
                  subtitle: '(0%)',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.cancel_outlined,
                  title: 'Thất bại',
                  value: '0',
                  subtitle: '(0%)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum CheckOrderMethod { scanQrOrBarcode, manual }

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
  late BuildContext _parentContext;
  late DeliveryRouteEntity _deliveryRoute;
  late CheckOrderMethod _method = CheckOrderMethod.scanQrOrBarcode;

  @override
  void initState() {
    super.initState();
    _parentContext = widget.context;
    _deliveryRoute = widget.route;
  }

  @override
  void didUpdateWidget(covariant _RouteActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.context != widget.context) {
        _parentContext = widget.context;
      }
      if (oldWidget.route != widget.route) {
        _deliveryRoute = widget.route;
      }
    });
  }

  void changeCheckOrderMethod({required CheckOrderMethod value}) {
    setState(() {
      _method = value;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: _buildAction(context: context, currentMethod: _method),
        ),
      ),
    );
  }

  Widget _buildAction({
    required BuildContext context,
    required CheckOrderMethod currentMethod,
  }) {
    final deliveryOrderPageCubit = context.read<DeliveryOrderPageCubit>();
    final selectionCubit = context.read<SelectionCubit<String>>();

    if (_deliveryRoute.status == DeliveryRouteStatus.pending.value) {
      return Row(
        children: [
          const SizedBox(width: 12),

          _OutlineButton(
            icon: Icons.add,
            label: 'Thêm đơn',
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
              label: 'Kiểm tra lại',
              subtitle: 'Kiểm tra lại các đơn đã chọn',
              onPressed: () {
                AppDialogUtils.showCustomDialog(
                  primaryColor: AppColors.primary,
                  context: context,
                  title: 'Bạn có chắc kiểm tra lại các đơn hàng đã chọn chứ?',
                  subtitle:
                      '${selectionCubit.state.selectedItems.length} đơn hàng đã chọn sẽ được đưa vào danh sách chờ kiểm tra.',
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: 'Huỷ',
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: 'Xác nhận',
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
            icon: Icons.touch_app_outlined,
            label: 'Xác nhận đơn hàng',
            subtitle: currentMethod == CheckOrderMethod.scanQrOrBarcode
                ? 'Quét QR hoặc Barcode'
                : 'Thủ công',
            onPressed: () {
              if (currentMethod == CheckOrderMethod.scanQrOrBarcode) {
                _openOrderScanScreen(context: context);
              } else {
                AppDialogUtils.showSuccess(
                  context: context,
                  title:
                      'Bạn có chắc đã kiểm tra thông tin của các đơn hàng đã chọn?',
                  subtitle:
                      'Lưu ý: Đảm bảo chính xác việc kiểm tra đơn hàng để hệ thống sắp xếp lộ trình chính xác và hiệu quả nhất cho bạn.',
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: 'Huỷ',
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: 'Xác nhận',
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
            onLongPress: () => _showCheckOrderOptionMethod(
              context: context,
              currentMethod: currentMethod,
              changeCheckOrderMethod: changeCheckOrderMethod,
            ),
          ),
          const SizedBox(width: 12),

          _OutlineButton(
            disabled: !_deliveryRoute.isAllChecked,
            icon: Icons.local_shipping_outlined,
            label: 'Sắp xếp hàng hoá',
            subtitle: 'Cần xác nhận đủ 100% đơn hàng',
            onPressed: () {
              AppDialogUtils.showSuccess(
                context: context,
                title: 'Bạn đã sẵn sàng sắp xếp hàng hoá hay chưa?',
                subtitle:
                    'Lưu ý: Đảm bảo chính xác việc kiểm tra đơn hàng để hệ thống sắp xếp lộ trình chính xác và hiệu quả nhất cho bạn.',
                actions: [
                  SmgoButton(
                    isOutlined: true,
                    text: 'Huỷ',
                    primaryColor: AppColors.primary,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  SmgoButton(
                    primaryColor: AppColors.primary,
                    text: 'Xác nhận',
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
            label: 'Quay lại kiểm tra đơn hàng',
            onPressed: () {
              if (_deliveryRoute.totalSortedOrders > 0) {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: 'Bạn có chắc muốn quay lại giai đoạn kiểm tra hàng?',
                  subtitle:
                      'Lưu ý: Sau khi thực hiện thao tác này bạn phải thực hiện sắp xếp lại vì việc thêm hoặc bớt đơn ở giai đoạn kiểm tra hàng có thể sẽ xáo trộn thứ tự sắp xếp hàng hoá',
                  actions: [
                    SmgoButton(
                      isOutlined: true,
                      text: 'Huỷ',
                      primaryColor: AppColors.primary,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SmgoButton(
                      primaryColor: AppColors.primary,
                      text: 'Xác nhận',
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

          _PrimaryButton(
            icon: Icons.local_shipping_outlined,
            label: _deliveryRoute.totalSortedOrders == 0
                ? 'Sắp xếp hàng hoá'
                : 'Sắp xếp lại hàng hoá',
            onPressed: () async {
              bool serviceEnabled;
              LocationPermission permission;

              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                if (context.mounted) {
                  AppDialogUtils.showError(
                    context: context,
                    title: 'Lỗi định vị',
                    subtitle: 'Vui lòng bật GPS trên thiết bị của bạn.',
                  );
                }
                return;
              }

              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  if (context.mounted) {
                    AppDialogUtils.showError(
                      context: context,
                      title: 'Từ chối quyền',
                      subtitle:
                          'Ứng dụng cần quyền truy cập vị trí để tối ưu tuyến đường từ điểm bạn đang đứng.',
                    );
                  }
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                if (context.mounted) {
                  AppDialogUtils.showError(
                    context: context,
                    title: 'Quyền bị từ chối vĩnh viễn',
                    subtitle:
                        'Vui lòng vào Cài đặt để cấp quyền vị trí cho ứng dụng.',
                  );
                }
                return;
              }

              try {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                if (_deliveryRoute.totalSortedOrders == 0) {
                  context.read<SortDeliveryOrdersCubit>().call(
                    deliveryRouteId: _deliveryRoute.id,
                    source: Point(x: position.longitude, y: position.latitude),
                  );
                } else {
                  if (context.mounted) {
                    AppDialogUtils.showSuccess(
                      context: context,
                      title: 'Bạn có chắc muốn sắp xếp lại hàng hoá?',
                      subtitle:
                          'Lưu ý: Thứ tự sắp xếp có thể đảo lộn nếu trước đó bạn đã thêm hoặc xoá bớt đơn hàng.',
                      actions: [
                        SmgoButton(
                          isOutlined: true,
                          text: 'Huỷ',
                          primaryColor: AppColors.primary,
                          onPressed: () {
                            context.pop();
                          },
                        ),
                        SmgoButton(
                          primaryColor: AppColors.primary,
                          text: 'Xác nhận',
                          onPressed: () {
                            context.read<SortDeliveryOrdersCubit>().call(
                              deliveryRouteId: _deliveryRoute.id,
                              source: Point(
                                x: position.longitude,
                                y: position.latitude,
                              ),
                            );
                            context.pop();
                          },
                        ),
                      ],
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  AppDialogUtils.showError(
                    context: context,
                    title: 'Không thể lấy vị trí',
                    subtitle:
                        'Đã xảy ra lỗi khi cố gắng lấy vị trí hiện tại của bạn.',
                  );
                }
              }
            },
          ),

          const SizedBox(width: 12),

          _OutlineButton(
            disabled: true,
            icon: Icons.play_arrow,
            label: 'Bắt đầu giao hàng',
            subtitle: 'Chỉ khả dụng khi sắp xếp 100%',
          ),

          const SizedBox(width: 12),
        ],
      );
    } else if (_deliveryRoute.status == DeliveryRouteStatus.delivering.value) {
      return Row(
        children: [
          _OutlineButton(
            icon: Icons.phone_outlined,
            label: 'Liên hệ',
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          _PrimaryButton(
            icon: Icons.navigation,
            label: 'Điều hướng đến điểm giao tiếp theo',
            subtitle: '67 Lê Lợi, P. Bến Nghé, Q.1, TP.HCM',
            onPressed: () {},
          ),
        ],
      );
    } else if (_deliveryRoute.status == DeliveryRouteStatus.completed.value) {
      return Row(
        children: [
          _OutlineButton(
            icon: Icons.assignment_outlined,
            label: 'Xem lại đơn hàng',
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          _PrimaryButton(
            icon: Icons.check_circle_outline,
            label: 'Về danh sách lộ trình',
            onPressed: () {},
          ),
        ],
      );
    } else {
      throw Exception('Delivery route status does not match any valid case');
    }
  }

  void _showCheckOrderOptionMethod({
    required BuildContext context,
    required CheckOrderMethod currentMethod,
    required void Function({required CheckOrderMethod value})
    changeCheckOrderMethod,
  }) {
    AppDialogUtils.showCustomDialog(
      context: context,
      iconData: Icons.fact_check_outlined,
      title: 'Chọn phương thước kiểm tra hàng hoá',
      subtitle: 'Vui lòng chọn một phương thức',
      content: Column(
        children: [
          OptionButton(
            icon: Icons.qr_code_scanner,
            title: 'Quét mã QR hoặc Barcode',
            subtitle:
                'Sử dụng camera để quét nhanh mã QR hoặc Barcode dán trên gói hàng',
            onTap: () {
              changeCheckOrderMethod(value: CheckOrderMethod.scanQrOrBarcode);
              context.pop();
            },
            isChosen: currentMethod == CheckOrderMethod.scanQrOrBarcode,
          ),
          SizedBox(height: 8),
          OptionButton(
            icon: Icons.checklist,
            title: 'Kiểm tra thủ công',
            subtitle: 'Tự xác nhận và đối soát danh sách hàng hóa bằng tay',
            onTap: () {
              changeCheckOrderMethod(value: CheckOrderMethod.manual);
              context.pop();
            },
            isChosen: currentMethod == CheckOrderMethod.manual,
          ),
        ],
      ),
    );
  }

  void _openOrderScanScreen({required BuildContext context}) {
    final getDeliveryRoutesCubitInParent = context
        .read<GetDeliveryRoutesCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: "Quét thông tin đơn hàng",
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
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Không tìm thấy đơn hàng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mã này không tồn tại hoặc không phù hợp với hệ thống. Vui lòng thử lại.",
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
                        child: const Text(
                          "Quét mã khác",
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
                          "Mã vận đơn",
                          order.orderCode,
                          showCopy: true,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          "Tên sản phẩm",
                          order.orderName == null ||
                                  (order.orderName != null &&
                                      order.orderName!.isNotEmpty)
                              ? order.orderName!
                              : 'Không có tên đơn hàng',
                          showCopy: true,
                        ),

                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.person_outline,
                          "Tên người nhận",
                          order.contactName,
                          showCopy: true,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.phone_outlined,
                          "Số điện thoại",
                          order.contactPhone,
                          showCopy: true,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          "Địa chỉ nhận",
                          order.address,
                          showCopy: true,
                        ),
                        const Divider(height: 24, color: Colors.black12),

                        _buildImageRow(
                          "Ảnh đơn hàng",
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
                              title: 'Xác nhận thành công!',
                              subtitle:
                                  'Đơn hàng có mã vận đơn ${order.orderCode} đã được xác nhận.',
                            );
                          } else if (state is ConfirmDeliveryOrdersFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: 'Xác nhận đơn hàng thất bại',
                              subtitle: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
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
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Quét lại",
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
                                      order.status == 'checked',
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
                                              order.status == 'checked'
                                                  ? 'Đã xác nhận'
                                                  : "Xác nhận",
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

  // Helper Widget dựng dòng thông tin đơn giản
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showCopy = false,
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
              copyToClipboard(value);
            },
            icon: Icon(Icons.copy, size: 18, color: Color(0xFF006837)),
          ),
      ],
    );
  }

  void copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào bộ nhớ tạm!'),
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
            const Icon(
              Icons.image_outlined,
              size: 20,
              color: Color(0xFF006837),
            ),
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
              errorBuilder: (_, _, _) => const Center(
                child: Text(
                  "Không có ảnh",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RouteColors.green,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 8),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
            subtitleColor: RouteColors.green.withOpacity(0.8),
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
        familiar ? 'Khách quen' : 'Khách lạ',
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

class _TabItem extends StatelessWidget {
  final String title;
  final bool active;

  const _TabItem({required this.title, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? RouteColors.green : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? RouteColors.green : RouteColors.text,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CompletedTabs extends StatelessWidget {
  const _CompletedTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _TabItem(title: 'Tổng quan', active: true)),
          Expanded(child: _TabItem(title: 'Đơn hàng')),
          Expanded(child: _TabItem(title: 'Thống kê')),
          Expanded(child: _TabItem(title: 'Ghi chú')),
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

  const _StatisticItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: RouteColors.greenLight,
          ),
          child: Icon(icon, color: RouteColors.green, size: 22),
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
