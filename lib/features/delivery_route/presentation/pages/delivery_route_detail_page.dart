import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_button.dart';
import 'package:shipgo/shared/utils/app_dialog_utils.dart';

class DeliveryRouteDetailPage extends StatefulWidget {
  const DeliveryRouteDetailPage({super.key});

  @override
  State<DeliveryRouteDetailPage> createState() =>
      _DeliveryRouteDetailPageState();
}

class _DeliveryRouteDetailPageState extends State<DeliveryRouteDetailPage> {
  DeliveryRouteEntity? deliveryRoute;

  // Khai báo màu sắc chủ đạo
  static const Color primaryGreen = AppColors.primary;
  static const Color successColor = Color(0xFF0F7A41);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFED6C02);
  static const Color infoColor = Color(0xFF0288D1);
  static const Color checkedColor = Color(0xFF00897B);
  static const Color uncheckedColor = Color(0xFF78909C);

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final getDeliveryRoutesCubitInRP =
        extra['GetDeliveryRoutesCubicInRP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInRP =
        extra['GetDeliveryRoutesUsecaseParamsInRP']
            as GetDeliveryRoutesUsecaseParams;
    deliveryRoute =
        deliveryRoute ?? extra['DeliveryRouteData'] as DeliveryRouteEntity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          AppStrings.rDPTitle.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di<GetDeliveryRoutesCubit>()
              ..call(
                params: GetDeliveryRoutesUsecaseParams(
                  pageNumber: 1,
                  pageSize: 1,
                  id: deliveryRoute!.id,
                ),
              ),
          ),
          BlocProvider<DeleteDeliveryRoutesCubit>(
            create: (context) => di<DeleteDeliveryRoutesCubit>(),
          ),
        ],
        child: BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
          listener: (context, state) {
            if (state is GetDeliveryRoutesDone) {
              deliveryRoute = state.routes.firstOrNull;
              getDeliveryRoutesCubitInRP.call(
                params: getDeliveryRoutesUsecaseParamsInRP,
              );
            }
          },
          builder: (context, state) {
            if (state.isFirstLoad) {
              if (state is GetDeliveryRoutesLoading) {
                return Center(child: CircularProgressIndicator());
              }
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<GetDeliveryRoutesCubit>().call(
                  params: GetDeliveryRoutesUsecaseParams(
                    pageNumber: 1,
                    pageSize: 1,
                    id: deliveryRoute!.id,
                  ),
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeaderCard(
                      deliveryRouteData: deliveryRoute!,
                      context: context,
                      getDeliveryRoutesCubitInRP: getDeliveryRoutesCubitInRP,
                      getDeliveryRoutesUsecaseParamsInRP:
                          getDeliveryRoutesUsecaseParamsInRP,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailInfoCard(deliveryRouteData: deliveryRoute!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Card 1: Thống kê & Thao tác
  Widget _buildHeaderCard({
    required DeliveryRouteEntity deliveryRouteData,
    required BuildContext context,
    required GetDeliveryRoutesCubit getDeliveryRoutesCubitInRP,
    required GetDeliveryRoutesUsecaseParams getDeliveryRoutesUsecaseParamsInRP,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
      ),
      child: Column(
        children: [
          // Tiêu đề lộ trình
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deliveryRouteData.name,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    AppStrings.rDPCreatedRouteDateString.tr(
                                      namedArgs: {
                                        'dateTimeString':
                                            DateFormat(
                                              'dd/MM/yyyy • HH:mm',
                                            ).format(
                                              deliveryRouteData.createdAt
                                                  .toLocal(),
                                            ),
                                      },
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Nút chỉnh sửa thông tin lộ trình
                        IconButton.outlined(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: const CircleBorder(),
                          ),
                          onPressed: () {
                            final getDeliveryRoutesCubitInRDP = context
                                .read<GetDeliveryRoutesCubit>();
                            context.pushNamed(
                              AppRouteNames.updateDeliveryRoute,
                              pathParameters: {'id': deliveryRouteData.id},
                              extra: <String, Object>{
                                'DeliveryRouteData':
                                    getDeliveryRoutesCubitInRDP
                                        .state
                                        .routes
                                        .firstOrNull ??
                                    deliveryRouteData,
                                'GetDeliveryRoutesUsecaseParamsInDRDP':
                                    GetDeliveryRoutesUsecaseParams(
                                      id: deliveryRouteData.id,
                                      pageNumber: 1,
                                      pageSize: 1,
                                    ),
                                'GetDeliveryRoutesCubitInDRDP':
                                    getDeliveryRoutesCubitInRDP,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Hàng chỉ số thống kê
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.check_circle_outline,
                iconColor: successColor,
                value: deliveryRouteData.totalDeliveredOrders.toString(),
                valueColor: successColor,
                label: AppStrings.rDPSuccessCountLabel.tr(),
              ),
              _StatItem(
                icon: Icons.highlight_off,
                iconColor: errorColor,
                value: deliveryRouteData.totalCancelledOrders.toString(),
                valueColor: errorColor,
                label: AppStrings.rDPFailedCountLabel.tr(),
              ),
              _StatItem(
                icon: Icons.access_time_rounded,
                iconColor: warningColor,
                value: deliveryRouteData.totalRescheduledOrders.toString(),
                valueColor: warningColor,
                label: AppStrings.rDPRescheduledCountLabel.tr(),
              ),
              _StatItem(
                icon: Icons.description_outlined,
                iconColor: infoColor,
                value: deliveryRouteData.totalOrders.toString(),
                valueColor: infoColor,
                label: AppStrings.rDPTotalCountLabel.tr(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Nút bấm action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final getDeliveryRoutesCubitInRDP = context
                        .read<GetDeliveryRoutesCubit>();
                    context.pushNamed(
                      AppRouteNames.deliveryOrder,
                      pathParameters: {'id': deliveryRouteData.id},
                      extra: <String, Object>{
                        'DeliveryRouteData':
                            getDeliveryRoutesCubitInRDP
                                .state
                                .routes
                                .firstOrNull ??
                            deliveryRouteData,
                        'GetDeliveryRoutesCubitInDRDP':
                            getDeliveryRoutesCubitInRDP,
                        'GetDeliveryRoutesUsecaseParamsInDRDP':
                            GetDeliveryRoutesUsecaseParams(
                              id: deliveryRouteData.id,
                              pageNumber: 1,
                              pageSize: 1,
                            ),
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: primaryGreen,
                  ),
                  label: Text(
                    AppStrings.rDPOrdersLabel.tr(),
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: primaryGreen, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nút xoá lộ trình
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final parentContext = context;
                    AppDialogUtils.showCustomDialog(
                      context: context,
                      title: AppStrings.rDPDeleteRouteDialogTitle.tr(),
                      subtitle: AppStrings.rDPDeleteRouteDialogContent.tr(),
                      barrierDismissible: false,
                      actions: [
                        BlocProvider<DeleteDeliveryRoutesCubit>(
                          create: (_) => di<DeleteDeliveryRoutesCubit>(),
                          child:
                              BlocConsumer<
                                DeleteDeliveryRoutesCubit,
                                DeleteDeliveryRoutesState
                              >(
                                listener: (consumerContext, dialogState) {
                                  if (dialogState is DeleteDeliveryRoutesDone) {
                                    getDeliveryRoutesCubitInRP.call(
                                      params:
                                          getDeliveryRoutesUsecaseParamsInRP,
                                    );

                                    context.pop();

                                    if (parentContext.mounted) {
                                      parentContext.pop();
                                    }

                                    AppDialogUtils.showSuccess(
                                      context: context,
                                      title: 'Xoá lộ trình thành công!',
                                    );
                                  } else if (dialogState
                                      is DeleteDeliveryRoutesFailed) {
                                    AppDialogUtils.showError(
                                      context: context,
                                      title: 'Xoá lộ trình thất bại!',
                                      subtitle:
                                          'Đã xảy ra lỗi. Vui lòng thử lại.',
                                    );
                                  }
                                },
                                builder: (consumerContext, dialogState) {
                                  final isLoading =
                                      dialogState
                                          is DeleteDeliveryRoutesLoading;

                                  return IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: SmgoButton(
                                            isDisabled: isLoading,
                                            primaryColor: AppColors.primary,
                                            text: AppStrings
                                                .rDPDeleteRouteDialogCancelBtnTitle
                                                .tr(),
                                            isOutlined: true,
                                            onPressed: () {
                                              consumerContext.pop();
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: SmgoButton(
                                            isDisabled: isLoading,
                                            primaryColor: AppColors.primary,
                                            onPressed: () {
                                              consumerContext
                                                  .read<
                                                    DeleteDeliveryRoutesCubit
                                                  >()
                                                  .call([deliveryRouteData.id]);
                                            },
                                            child: isLoading
                                                ? const SizedBox(
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
                                                        .rDPDeleteRouteDialogDeleteBtnTitle
                                                        .tr(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: errorColor,
                  ),
                  label: Text(
                    AppStrings.rDPDeleteRouteBtnLabel.tr(),
                    style: TextStyle(
                      color: errorColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: errorColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Danh sách thông tin chi tiết
  Widget _buildDetailInfoCard({
    required DeliveryRouteEntity deliveryRouteData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.rDPInfoDetailTitle.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _buildDetailRow(
            icon: Icons.calendar_month_outlined,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: primaryGreen,
            title: AppStrings.rDPCreatedRouteDateLabel.tr(),
            value: DateFormat(
              'dd/MM/yyyy • HH:mm',
            ).format(deliveryRouteData.createdAt.toLocal()),
            valueColor: Colors.black87,
          ),
          _buildDetailRow(
            icon: Icons.tag,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: primaryGreen,
            title: AppStrings.rDPDeliveryRouteIdLabel.tr(),
            value: deliveryRouteData.id,
            valueColor: Colors.black87,
            showCopy: true,
          ),
          _buildDetailRow(
            icon: Icons.pending_actions_outlined,
            iconBgColor: Colors.transparent,
            iconColor: uncheckedColor,
            title: AppStrings.rDPTotalUncheckedOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalPendingOrders.toString(),
              },
            ),
            valueColor: uncheckedColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.fact_check_outlined,
            iconBgColor: Colors.transparent,
            iconColor: checkedColor,
            title: AppStrings.rDPTotalCheckedOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalCheckedOrders.toString(),
              },
            ),
            valueColor: checkedColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.inventory_2_outlined,
            iconBgColor: Colors.transparent,
            iconColor: checkedColor,
            title: AppStrings.rDPTotalUnsortedOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity':
                    (deliveryRouteData.totalOrders -
                            deliveryRouteData.totalSortedOrders)
                        .toString(),
              },
            ),
            valueColor: checkedColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.inventory_2,
            iconBgColor: Colors.transparent,
            iconColor: checkedColor,
            title: AppStrings.rDPTotalSortedOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalSortedOrders.toString(),
              },
            ),
            valueColor: checkedColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.check_circle_outline,
            iconBgColor: Colors.transparent,
            iconColor: successColor,
            title: AppStrings.rDPTotalSuccessOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalDeliveredOrders.toString(),
              },
            ),
            valueColor: successColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.highlight_off,
            iconBgColor: Colors.transparent,
            iconColor: errorColor,
            title: AppStrings.rDPTotalFailedOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalCancelledOrders.toString(),
              },
            ),
            valueColor: errorColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            iconBgColor: Colors.transparent,
            iconColor: warningColor,
            title: AppStrings.rDPTotalRescheduledOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {
                'quantity': deliveryRouteData.totalRescheduledOrders.toString(),
              },
            ),
            valueColor: warningColor,
            valueFontWeight: FontWeight.bold,
          ),
          _buildDetailRow(
            icon: Icons.description_outlined,
            iconBgColor: Colors.transparent,
            iconColor: infoColor,
            title: AppStrings.rDPTotalOrdersLabel.tr(),
            value: AppStrings.rDPCountContent.tr(
              namedArgs: {'quantity': deliveryRouteData.totalOrders.toString()},
            ),
            valueColor: infoColor,
            valueFontWeight: FontWeight.bold,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    FontWeight valueFontWeight = FontWeight.normal,
    bool showCopy = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(width: 20),

              // Value + Copy
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: valueColor,
                          fontWeight: valueFontWeight,
                        ),
                      ),
                    ),

                    if (showCopy) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          _copyToClipboard(value);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(
                          Icons.copy,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào bộ nhớ tạm!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Widget con hiển thị từng ô chỉ số cột
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final Color valueColor;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
