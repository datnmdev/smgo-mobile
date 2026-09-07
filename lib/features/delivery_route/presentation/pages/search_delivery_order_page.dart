import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_orders/search_delivery_orders_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_orders/search_delivery_orders_state.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_generic_scan_screen.dart';
import 'package:smgo/shared/utils/app_audio_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchDeliveryOrderPage extends StatefulWidget {
  const SearchDeliveryOrderPage({super.key});

  @override
  State<SearchDeliveryOrderPage> createState() =>
      _SearchDeliveryOrderPageState();
}

class _SearchDeliveryOrderPageState extends State<SearchDeliveryOrderPage> {
  DeliveryRouteEntity? _deliveryRoute;
  final TextEditingController _searchController = TextEditingController(
    text: "",
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    _deliveryRoute =
        _deliveryRoute ??
        extra['DeliveryRouteDataInDOP'] as DeliveryRouteEntity;
    final getDeliveryRoutesCubitInDOP =
        extra['GetDeliveryRoutesCubitInDOP'] == null
        ? null
        : extra['GetDeliveryRoutesCubitInDOP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDOP =
        extra['GetDeliveryRoutesUsecaseParamsInDOP'] == null
        ? null
        : extra['GetDeliveryRoutesUsecaseParamsInDOP']
              as GetDeliveryRoutesUsecaseParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchDeliveryOrdersCubit>(
          create: (_) => di<SearchDeliveryOrdersCubit>(),
        ),
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (_) => di<GetDeliveryRoutesCubit>(),
        ),
      ],
      child: BlocListener<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
        listener: (context, state) {
          if (state is GetDeliveryRoutesDone) {
            setState(() {
              _deliveryRoute = state.routes.firstOrNull ?? _deliveryRoute;
            });
          }
        },
        child:
            BlocConsumer<SearchDeliveryOrdersCubit, SearchDeliveryOrdersState>(
              listener: (context, state) {
                if (state is SearchDeliveryOrdersDone) {
                  if (getDeliveryRoutesCubitInDOP != null &&
                      getDeliveryRoutesUsecaseParamsInDOP != null) {
                    getDeliveryRoutesCubitInDOP.call(
                      params: getDeliveryRoutesUsecaseParamsInDOP,
                    );
                  }
                  context.read<GetDeliveryRoutesCubit>().call(
                    params: GetDeliveryRoutesUsecaseParams(
                      pageNumber: 1,
                      pageSize: 1,
                      id: _deliveryRoute!.id,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final searchDeliveryOrdersCubit = context
                    .read<SearchDeliveryOrdersCubit>();
                final isLoading = state is SearchDeliveryOrdersLoading;
                final orders = state is SearchDeliveryOrdersDone
                    ? state.data
                    : [];

                return Scaffold(
                  backgroundColor: const Color(0xFFF5F6F8),
                  body: Column(
                    children: [
                      // Header màu xanh lá cây
                      Container(
                        color: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.paddingOf(context).top),
                            Row(
                              children: [
                                // Nút back
                                IconButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Tiêu đề
                                Expanded(
                                  child: Text(
                                    AppStrings.sDOPTitle.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                ), // Cân bằng khoảng trống với nút back
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Thanh tìm kiếm
                      Container(
                        color: AppColors.primary,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            autofocus: true,
                            controller: _searchController,
                            onChanged: (value) {
                              searchDeliveryOrdersCubit.searchTextChanged(
                                value,
                              );
                              searchDeliveryOrdersCubit.submit(
                                deliveryRouteId: _deliveryRoute!.id,
                              );
                            },
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.sDOPSearchHintText.tr(),
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              prefixIcon: state is SearchDeliveryOrdersLoading
                                  ? const UnconstrainedBox(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                              suffixIcon: state.searchText.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        searchDeliveryOrdersCubit.reset();
                                        searchDeliveryOrdersCubit.submit(
                                          deliveryRouteId: _deliveryRoute!.id,
                                        );
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                top: 12,
                                bottom: 12,
                                right: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Skeletonizer(
                          enabled: isLoading,
                          child: Column(
                            children: [
                              // Thanh kết quả tìm kiếm
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isLoading
                                          ? AppStrings
                                                .sDOPSearchResultLoadingContent
                                                .tr()
                                          : AppStrings
                                                .sDOPSearchResultCountContent
                                                .tr(
                                                  namedArgs: {
                                                    'quantity': orders.length
                                                        .toString(),
                                                  },
                                                ),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Danh sách đơn hàng
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: isLoading ? 0 : orders.length,
                                  itemBuilder: (context, index) {
                                    if (isLoading) {
                                      return _buildSkeletonOrderCard();
                                    }

                                    final order = orders[index];

                                    return _buildOrderCard(
                                      order: order,
                                      deliveryRouteData: _deliveryRoute!,
                                      context: context,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Phần quét mã vạch ở dưới cùng
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.sDOPOrderNotFoundQuestion.tr(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _openOrderScanScreenToFindOrder(
                                    context: context,
                                    deliveryRoute: _deliveryRoute!,
                                  );
                                },
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Color(0xFF10A142),
                                ),
                                label: Text(
                                  AppStrings.sDOPScanOrderButtonLabel.tr(),
                                  style: TextStyle(
                                    color: Color(0xFF10A142),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF10A142),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  void _openOrderScanScreenToFindOrder({
    required BuildContext context,
    required DeliveryRouteEntity deliveryRoute,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmgoGenericScanScreen<DeliveryOrderEntity?>(
          title: AppStrings.sDOPScanOrderTitle.tr(),
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
                      AppStrings.sDOPOrderNotFoundTitle.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.sDOPOrderNotFoundContent.tr(),
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
                          AppStrings.sDOPScanAnotherOrderButtonLabel.tr(),
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
                        AppStrings.sDOPOrderCodeLabel.tr(),
                        order.orderCode,
                        showCopy: true,
                        context: context,
                      ),

                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.inventory_2_outlined,
                        AppStrings.sDOPProductNameLabel.tr(),
                        order.orderName?.isNotEmpty == true
                            ? order.orderName!
                            : AppStrings.sDOPNoOrderName.tr(),
                        showCopy: true,
                        context: context,
                      ),

                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.person_outline,
                        AppStrings.sDOPRecipientNameLabel.tr(),
                        order.contactName,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.phone_outlined,
                        AppStrings.sDOPPhoneNumberLabel.tr(),
                        order.contactPhone,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildInfoRow(
                        Icons.location_on_outlined,
                        AppStrings.sDOPDeliveryAddressLabel.tr(),
                        order.address,
                        showCopy: true,
                        context: context,
                      ),
                      const Divider(height: 24, color: Colors.black12),

                      _buildImageRow(
                        AppStrings.sDOPOrderImageLabel.tr(),
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
                                AppStrings.sDOPScanAgainButtonLabel.tr(),
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
                                'SearchDeliveryOrdersCubitInSDOP': context
                                    .read<SearchDeliveryOrdersCubit>(),
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
                                AppStrings.sDOPViewDetailButtonLabel.tr(),
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

  Widget _buildSkeletonOrderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Bone.square(size: 38, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 12),

              Expanded(child: Bone.text(words: 2)),

              Bone(
                width: 75,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),

              const SizedBox(width: 8),

              Bone.icon(size: 20),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.icon(size: 16),
              const SizedBox(width: 6),
              const Expanded(child: Bone.text(words: 6)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị từng thẻ đơn hàng
  Widget _buildOrderCard({
    required DeliveryOrderEntity order,
    required DeliveryRouteEntity deliveryRouteData,
    required BuildContext context,
  }) {
    late final DeliveryOrderStatus status;

    if (order.status == DeliveryOrderStatus.pending.value) {
      status = DeliveryOrderStatus.pending;
    } else if (order.status == DeliveryOrderStatus.checked.value) {
      if (deliveryRouteData.status == DeliveryRouteStatus.pending.value) {
        status = DeliveryOrderStatus.checked;
      } else {
        status = DeliveryOrderStatus.sorting;
      }
    } else if (order.status == DeliveryOrderStatus.sorted.value) {
      if (deliveryRouteData.status == DeliveryRouteStatus.sorting.value) {
        status = DeliveryOrderStatus.sorted;
      } else {
        status = DeliveryOrderStatus.delivering;
      }
    } else if (order.status == DeliveryOrderStatus.delivered.value) {
      status = DeliveryOrderStatus.delivered;
    } else if (order.status == DeliveryOrderStatus.cancelled.value) {
      status = DeliveryOrderStatus.cancelled;
    } else if (order.status == DeliveryOrderStatus.rescheduled.value) {
      status = DeliveryOrderStatus.rescheduled;
    } else {
      throw Exception('Delivery order status does not match any valid case');
    }

    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: statusColor.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: statusColor.withAlpha(20),
          highlightColor: statusColor.withAlpha(10),
          onTap: () {
            context.pushNamed(
              AppRouteNames.deliveryOrderDetail,
              pathParameters: {
                'id': order.deliveryRouteId,
                'deliveryOrderId': order.id,
              },
              extra: <String, Object>{
                'DeliveryRouteData': deliveryRouteData,
                'DeliveryOrderData': order,
                'SearchDeliveryOrdersCubitInSDOP': context
                    .read<SearchDeliveryOrdersCubit>(),
              },
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dải màu trạng thái bên trái
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Icon trạng thái
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForStatus(status: status),
                                color: statusColor,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Mã đơn
                            Expanded(
                              child: Text(
                                order.orderCode,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            _buildStatusBadge(status: status),

                            const SizedBox(width: 8),

                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Địa chỉ giao hàng
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: statusColor.withAlpha(180),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                order.address,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // Helper trả về nhãn trạng thái và màu sắc phù hợp cho từng trạng thái mới
  Widget _buildStatusBadge({required DeliveryOrderStatus status}) {
    String text = '';
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;

    switch (status) {
      case DeliveryOrderStatus.pending:
        text = AppStrings.sDOPPendingStatusLabel.tr();
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF10A142);
        break;
      case DeliveryOrderStatus.checked:
        text = AppStrings.sDOPCheckedStatusLabel.tr();
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case DeliveryOrderStatus.sorting:
        text = AppStrings.sDOPSortingStatusLabel.tr();
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        break;
      case DeliveryOrderStatus.sorted:
        text = AppStrings.sDOPSortedStatusLabel.tr();
        bgColor = const Color(0xFFE0F7FA);
        textColor = const Color(0xFF00838F);
        break;
      case DeliveryOrderStatus.delivering:
        text = AppStrings.sDOPDeliveringStatusLabel.tr();
        bgColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF7B1FA2);
        break;
      case DeliveryOrderStatus.delivered:
        text = AppStrings.sDOPDeliveredStatusLabel.tr();
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF3F51B5);
        break;
      case DeliveryOrderStatus.cancelled:
        text = AppStrings.sDOPCancelledStatusLabel.tr();
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      case DeliveryOrderStatus.rescheduled:
        text = AppStrings.sDOPRescheduledStatusLabel.tr();
        bgColor = const Color(0xFFFFFDE7);
        textColor = const Color(0xFFFBC02D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper lấy icon theo trạng thái
  IconData _getIconForStatus({required DeliveryOrderStatus status}) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Icons.shopping_bag_outlined;
      case DeliveryOrderStatus.checked:
        return Icons.card_travel;
      case DeliveryOrderStatus.sorting:
        return Icons.local_shipping_outlined;
      case DeliveryOrderStatus.sorted:
        return Icons.inventory;
      case DeliveryOrderStatus.delivering:
        return Icons.near_me_outlined;
      case DeliveryOrderStatus.delivered:
        return Icons.done_all;
      case DeliveryOrderStatus.cancelled:
        return Icons.cancel_outlined;
      case DeliveryOrderStatus.rescheduled:
        return Icons.event_repeat;
    }
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return const Color(0xFF78909C); // Xám xanh

      case DeliveryOrderStatus.checked:
        return const Color(0xFF1976D2); // Xanh dương

      case DeliveryOrderStatus.sorting:
        return const Color(0xFFF57C00); // Cam

      case DeliveryOrderStatus.sorted:
        return const Color(0xFF00838F); // Xanh teal

      case DeliveryOrderStatus.delivering:
        return const Color(0xFF7B1FA2); // Tím

      case DeliveryOrderStatus.delivered:
        return const Color(0xFF2E7D32); // Xanh lá đậm

      case DeliveryOrderStatus.cancelled:
        return const Color(0xFFC62828); // Đỏ

      case DeliveryOrderStatus.rescheduled:
        return const Color(0xFFF9A825); // Vàng
    }
  }

  Color _getStatusBgColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return const Color(0xFFECEFF1);

      case DeliveryOrderStatus.checked:
        return const Color(0xFFE3F2FD);

      case DeliveryOrderStatus.sorting:
        return const Color(0xFFFFF3E0);

      case DeliveryOrderStatus.sorted:
        return const Color(0xFFE0F7FA);

      case DeliveryOrderStatus.delivering:
        return const Color(0xFFF3E5F5);

      case DeliveryOrderStatus.delivered:
        return const Color(0xFFE8F5E9);

      case DeliveryOrderStatus.cancelled:
        return const Color(0xFFFFEBEE);

      case DeliveryOrderStatus.rescheduled:
        return const Color(0xFFFFFDE7);
    }
  }
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
      content: Text(AppStrings.sDOPCopiedToClipboardMessage.tr()),
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
                AppStrings.sDOPNoImage.tr(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
