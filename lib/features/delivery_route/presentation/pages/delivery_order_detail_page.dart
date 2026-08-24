import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/utils/external_url_util.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:shipgo/features/delivery_route/presentation/widgets/image_thumbnail.dart';
import 'package:shipgo/shared/helpers/app_dialog_helper.dart';
import 'package:shipgo/shared/widgets/google_map_screen.dart';
import 'package:shipgo/shared/widgets/m3_map.dart';
import 'package:shipgo/shared/widgets/smgo_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryOrderDetailPage extends StatefulWidget {
  const DeliveryOrderDetailPage({super.key});

  @override
  State<DeliveryOrderDetailPage> createState() =>
      _DeliveryOrderDetailPageState();
}

class _DeliveryOrderDetailPageState extends State<DeliveryOrderDetailPage> {
  DeliveryRouteEntity? deliveryRoute;
  DeliveryOrderEntity? deliveryOrder;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    deliveryRoute =
        deliveryRoute ?? (extra['DeliveryRouteData'] as DeliveryRouteEntity);
    deliveryOrder =
        deliveryOrder ?? (extra['DeliveryOrderData'] as DeliveryOrderEntity);
    final getDeliveryRoutesCubitInDOP =
        extra['GetDeliveryRoutesCubitInDOP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDOP =
        extra['GetDeliveryRoutesUsecaseParamsInDOP']
            as GetDeliveryRoutesUsecaseParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (context) => di<GetDeliveryRoutesCubit>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text(
            'Chi tiết đơn hàng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    deliveryOrder!.appliedLocationId != null
                        ? 'Khách quen'
                        : 'Khách lạ',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
          listener: (context, state) {
            if (state is GetDeliveryRoutesDone) {
              deliveryRoute = state.routes.firstOrNull ?? deliveryRoute;
              final res = state.routes.firstOrNull?.orders
                  .where((order) => order.id == deliveryOrder!.id)
                  .firstOrNull;
              if (res != null) {
                setState(() {
                  deliveryOrder = res;
                });
              }
              getDeliveryRoutesCubitInDOP.call(
                params: getDeliveryRoutesUsecaseParamsInDOP,
              );
            }
          },
          builder: (context, state) => RefreshIndicator(
            onRefresh: () async {
              await context.read<GetDeliveryRoutesCubit>().call(
                params: GetDeliveryRoutesUsecaseParams(
                  pageNumber: 1,
                  pageSize: 1,
                  id: deliveryOrder!.deliveryRouteId,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Mã đơn hàng & Mã vận đơn
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _buildCardDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mã vận đơn',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    deliveryOrder!.orderCode,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      copyToClipboard(deliveryOrder!.orderCode);
                                    },
                                    icon: Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Tên đơn hàng & Ảnh đơn hàng
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _buildCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tên đơn hàng',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bọc Text trong Expanded để nó tự động chiếm hết khoảng trống còn lại và xuống dòng
                            Expanded(
                              child: Text(
                                deliveryOrder!.orderName != null &&
                                        deliveryOrder!.orderName!.isNotEmpty
                                    ? deliveryOrder!.orderName!
                                    : 'Không có tên đơn hàng',
                                style: TextStyle(
                                  fontWeight:
                                      deliveryOrder!.orderName != null &&
                                          deliveryOrder!.orderName!.isNotEmpty
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                  color:
                                      deliveryOrder!.orderName != null &&
                                          deliveryOrder!.orderName!.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            if (deliveryOrder!.orderName != null) ...[
                              SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  copyToClipboard(deliveryOrder!.orderName!);
                                },
                                icon: Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Ảnh đơn hàng',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        if (deliveryOrder!.orderMediaUrl == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Chưa có ảnh đơn hàng',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ảnh đơn hàng sẽ hiển thị tại đây',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (deliveryOrder!.orderMediaUrl != null)
                                  ImageThumbnail(
                                    url: deliveryOrder!.orderMediaUrl!,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Thông tin người nhận
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _buildCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Thông tin người nhận',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.person,
                          'Tên người nhận',
                          deliveryOrder!.contactName,
                          showCopy: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.phone,
                          'Số điện thoại',
                          deliveryOrder!.contactPhone,
                          showCopy: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on,
                          'Địa chỉ',
                          deliveryOrder!.address,
                          showCopy: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Liên hệ người nhận
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _buildCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liên hệ người nhận',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildContactButton(
                                title: 'Gọi trực tiếp',
                                icon: Icons.phone,
                                color: primaryColor,
                                onPressed: () async {
                                  final url = ExternalUrlUtil.getDialUrl(
                                    deliveryOrder!.contactPhone,
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildContactButton(
                                title: 'Nhắn tin SMS',
                                icon: Icons.sms,
                                color: primaryColor,
                                onPressed: () async {
                                  final url = ExternalUrlUtil.getSmsUrl(
                                    phoneNumber: deliveryOrder!.contactPhone,
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildContactButton(
                                title: 'Nhắn Zalo',
                                icon: Icons.chat,
                                color: primaryColor,
                                onPressed: () async {
                                  final url = ExternalUrlUtil.getZaloUrl(
                                    deliveryOrder!.contactPhone,
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Vị trí & Điều hướng
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vị trí người nhận (Dùng Expanded ngang bên trong Row)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: _buildCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Vị trí người nhận',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${deliveryOrder!.location.y}, ${deliveryOrder!.location.x}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Đặt chiều cao cố định cho bản đồ thay vì dùng Expanded để tránh lỗi vô cực chiều cao
                                SizedBox(
                                  height: 110,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: M3MapWidget(
                                      initialZoom: 16.0,
                                      mode: MapMode.view,
                                      showControls: false,
                                      userAgentPackageName: Env.packageName,
                                      selectLocationError: AppStrings
                                          .m3MSelectLocationError
                                          .tr(),
                                      cannotGetLocationError: AppStrings
                                          .m3MCannotGetLocationError
                                          .tr(),
                                      mapTemplateUrl: Env.mapTemplateUrl,
                                      center: LatLng(
                                        deliveryOrder!.location.y,
                                        deliveryOrder!.location.x,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      side: BorderSide(color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GoogleMapsScreen(
                                                googleMapMode:
                                                    GoogleMapMode.view,
                                                title: 'Vị trí của người nhận',
                                                pinnedLocation: LatLng(
                                                  deliveryOrder!.location.y,
                                                  deliveryOrder!.location.x,
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.navigation,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      'Xem trên bản đồ',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Điều hướng
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: _buildCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Điều hướng',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildNavigationItem(
                                  title: 'Google Maps',
                                  subtitle: 'Mở bằng Google Maps',
                                  icon: Image.asset(AppAssets.icGoogleMaps),
                                  onTap: () async {
                                    final googleMapDirectionsUri =
                                        ExternalUrlUtil.getGoogleMapsDirectionsUri(
                                          destinationLat:
                                              deliveryOrder!.location.y,
                                          destinationLng:
                                              deliveryOrder!.location.x,
                                        );
                                    if (await canLaunchUrl(
                                      googleMapDirectionsUri,
                                    )) {
                                      await launchUrl(googleMapDirectionsUri);
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildNavigationItem(
                                  title: 'Bản đồ của app',
                                  subtitle: 'Mở bản đồ nội bộ',
                                  icon: Image.asset(AppAssets.logo),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 6. Trạng thái đơn hàng (Timeline)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _buildCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trạng thái đơn hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTimelineItem(
                          'Khởi tạo',
                          DateFormat(
                            'dd/MM/yyyy • HH:mm',
                          ).format(deliveryOrder!.createdAt.toLocal()),
                          isDone: true,
                          isFirst: true,
                          deliveryOrder: deliveryOrder!,
                        ),
                        _buildTimelineItem(
                          'Đã kiểm tra',
                          deliveryOrder!.checkedAt != null
                              ? DateFormat(
                                  'dd/MM/yyyy • HH:mm',
                                ).format(deliveryOrder!.checkedAt!.toLocal())
                              : '--/--/---- --:--',
                          isDone: deliveryOrder!.checkedAt != null,
                          deliveryOrder: deliveryOrder!,
                        ),
                        _buildTimelineItem(
                          'Đã sắp xếp',
                          deliveryOrder!.sortedAt != null
                              ? DateFormat(
                                  'dd/MM/yyyy • HH:mm',
                                ).format(deliveryOrder!.sortedAt!.toLocal())
                              : '--/--/---- --:--',
                          isDone: deliveryOrder!.sortedAt != null,
                          deliveryOrder: deliveryOrder!,
                        ),
                        _buildTimelineItem(
                          'Kết quả giao hàng',
                          '',
                          isDone:
                              deliveryOrder!.deliveredAt != null ||
                              deliveryOrder!.cancelledAt != null ||
                              deliveryOrder!.rescheduledAt != null,
                          isLast: true,
                          hasSubItems: true,
                          deliveryOrder: deliveryOrder!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
          builder: (context, state) => Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        context.pushNamed(
                          AppRouteNames.updateDeliveryOrder,
                          pathParameters: {
                            'id': deliveryOrder!.deliveryRouteId,
                            'deliveryOrderId': deliveryOrder!.id,
                          },
                          extra: <String, Object>{
                            'DeliveryRouteData': deliveryRoute!,
                            'DeliveryOrderData': deliveryOrder!,
                            'GetDeliveryRoutesCubitInDODP': context
                                .read<GetDeliveryRoutesCubit>(),
                            'GetDeliveryRoutesUsecaseParamsInDODP':
                                GetDeliveryRoutesUsecaseParams(
                                  pageNumber: 1,
                                  pageSize: 1,
                                  id: deliveryOrder!.deliveryRouteId,
                                ),
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: primaryColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Chỉnh sửa',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final parentContext = context;
                        AppDialogHelper.showCustomDialog(
                          context: context,
                          title: 'Bạn chắc chắn xoá đơn hàng này chứ?',
                          subtitle: 'Thông tin bị xoá không thể phục hồi.',
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
                                        getDeliveryRoutesCubitInDOP.call(
                                          params:
                                              getDeliveryRoutesUsecaseParamsInDOP,
                                        );
                                        context.pop();
                                        parentContext.pop();
                                      }
                                    },
                                    builder: (context, state) => IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: SmgoButton(
                                              isDisabled:
                                                  state
                                                      is DeleteDeliveryOrdersLoading,
                                              primaryColor: AppColors.primary,
                                              text: 'Huỷ',
                                              isOutlined: true,
                                              onPressed: () {
                                                context.pop();
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SmgoButton(
                                              isDisabled:
                                                  state
                                                      is DeleteDeliveryOrdersLoading,
                                              primaryColor: AppColors.primary,
                                              onPressed: () {
                                                context
                                                    .read<
                                                      DeleteDeliveryOrdersCubit
                                                    >()
                                                    .call([deliveryOrder!]);
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
                                                      'Xoá',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Xóa đơn hàng',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
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
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha((0.05 * 255).round()),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showCopy = false,
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: textColor ?? Colors.black87,
            ),
          ),
        ),
        if (showCopy) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {
              copyToClipboard(value);
            },
            icon: Icon(Icons.copy, size: 16, color: AppColors.primary),
          ),
        ],
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

  Widget _buildNavigationItem({
    required String title,
    required String subtitle,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          mouseCursor: SystemMouseCursors.click,

          splashColor: Colors.blue.withValues(alpha: 0.12),
          highlightColor: Colors.blue.withValues(alpha: 0.06),
          hoverColor: Colors.grey.withValues(alpha: 0.08),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 32, height: 32, child: Center(child: icon)),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String title,
    required IconData icon,
    required Color color,
    void Function()? onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time, {
    bool isDone = false,
    bool isFirst = false,
    bool isLast = false,
    bool hasSubItems = false,
    required DeliveryOrderEntity deliveryOrder,
  }) {
    const double nodeSize = 20;
    const double timelineWidth = 20;
    const double contentSpacing = 10;
    const double subItemHeight = 42;
    final subItemsDone = [
      deliveryOrder.deliveredAt != null,
      deliveryOrder.cancelledAt != null,
      deliveryOrder.rescheduledAt != null,
    ];
    final activeSubIndex = subItemsDone.indexWhere((isDone) => isDone);
    final hasActiveSubItem = activeSubIndex != -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// =========================
        /// PARENT TIMELINE ITEM
        /// =========================
        SizedBox(
          height: hasSubItems ? 32 : (isLast ? nodeSize : 45),
          child: Stack(
            children: [
              /// Đường nối từ node cha xuống cây con
              if (!isLast || hasSubItems)
                Positioned(
                  left: (timelineWidth - 1.5) / 2,
                  top: nodeSize,
                  bottom: 0,
                  child: Container(
                    width: 1.5,

                    /// Nếu có sub item hoàn thành
                    /// thì đường từ cha xuống sẽ sáng
                    color: hasSubItems && hasActiveSubItem
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                ),

              /// Parent node
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.green.shade50 : Colors.grey.shade100,
                    border: Border.all(
                      color: isDone ? Colors.green : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check : Icons.circle,
                      size: isDone ? 12 : 6,
                      color: isDone ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),

              /// Parent content
              Positioned(
                left: timelineWidth + contentSpacing,
                right: 0,
                top: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDone ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// =========================
        /// CHILD TIMELINE ITEMS
        /// =========================
        if (hasSubItems) ...[
          _buildConnectedSubTimelineItem(
            'Đã giao thành công',
            deliveryOrder.deliveredAt != null
                ? DateFormat(
                    'dd/MM/yyyy • HH:mm',
                  ).format(deliveryOrder.deliveredAt!.toLocal())
                : '--/--/---- --:--',
            Icons.check_circle_outline,
            height: subItemHeight,
            isDone: activeSubIndex == 0,
            isPathActive: activeSubIndex >= 0,
            isActiveItem: activeSubIndex == 0,
            isLast: false,
          ),

          _buildConnectedSubTimelineItem(
            'Đã giao thất bại',
            deliveryOrder.cancelledAt != null
                ? DateFormat(
                    'dd/MM/yyyy • HH:mm',
                  ).format(deliveryOrder.cancelledAt!.toLocal())
                : '--/--/---- --:--',
            Icons.cancel_outlined,
            height: subItemHeight,
            isDone: activeSubIndex == 1,
            isPathActive: activeSubIndex >= 1,
            isActiveItem: activeSubIndex == 1,
            isLast: false,
          ),

          _buildConnectedSubTimelineItem(
            'Hẹn giao sau',
            deliveryOrder.rescheduledAt != null
                ? DateFormat(
                    'dd/MM/yyyy • HH:mm',
                  ).format(deliveryOrder.rescheduledAt!.toLocal())
                : '--/--/---- --:--',
            Icons.access_time,
            height: subItemHeight,
            isDone: activeSubIndex == 2,
            isPathActive: activeSubIndex >= 2,
            isActiveItem: activeSubIndex == 2,
            isLast: true,
          ),
        ],
      ],
    );
  }

  Widget _buildConnectedSubTimelineItem(
    String title,
    String time,
    IconData icon, {
    required double height,
    bool isDone = false,

    /// Đường từ phía trên xuống item này có active không
    bool isPathActive = false,

    /// Đây có phải node kết quả cuối cùng không
    bool isActiveItem = false,

    bool isLast = false,
  }) {
    const double parentLineX = 9.25;
    const double childNodeLeft = 30;
    const double childNodeSize = 20;
    const double nodeCenterY = 20;

    final activeColor = Colors.green;
    final inactiveColor = Colors.grey.shade300;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          /// ========================================
          /// ĐƯỜNG DỌC - TỪ TRÊN XUỐNG NODE CON
          /// ========================================
          Positioned(
            left: parentLineX,
            top: 0,
            height: nodeCenterY,
            child: Container(
              width: 1.5,
              color: isPathActive ? activeColor : inactiveColor,
            ),
          ),

          /// ========================================
          /// ĐƯỜNG DỌC - SAU NODE CON
          /// Chỉ xanh nếu đường active còn tiếp tục
          /// xuống item phía dưới
          /// ========================================
          if (!isLast)
            Positioned(
              left: parentLineX,
              top: nodeCenterY,
              bottom: 0,
              child: Container(
                width: 1.5,

                /// Nếu kết quả chưa nằm ở item hiện tại
                /// thì đường active tiếp tục xuống dưới
                color: isPathActive && !isActiveItem
                    ? activeColor
                    : inactiveColor,
              ),
            ),

          /// ========================================
          /// ĐƯỜNG NGANG CHA → NODE CON
          /// Chỉ item đang active mới xanh
          /// ========================================
          Positioned(
            left: 10,
            top: nodeCenterY - 0.75,
            width: childNodeLeft - 10,
            child: Container(
              height: 1.5,
              color: isActiveItem ? activeColor : inactiveColor,
            ),
          ),

          /// ========================================
          /// NODE CON
          /// ========================================
          Positioned(
            left: childNodeLeft,
            top: nodeCenterY - childNodeSize / 2,
            child: Container(
              width: childNodeSize,
              height: childNodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? Colors.green.shade50 : Colors.white,
                border: Border.all(
                  color: isDone ? activeColor : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 14,
                  color: isDone ? activeColor : Colors.grey,
                ),
              ),
            ),
          ),

          /// ========================================
          /// TEXT
          /// ========================================
          Positioned(
            left: childNodeLeft + childNodeSize + 8,
            right: 0,
            top: nodeCenterY - 8,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDone ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
