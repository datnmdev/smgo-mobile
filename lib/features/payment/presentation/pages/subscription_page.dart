import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/payment/presentation/widgets/subscription_error.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/helpers/plan_ui_helper.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_state.dart';
import 'package:smgo/shared/presentation/bloc/subscription_purchase/subscription_purchase_cubit.dart';
import 'package:smgo/shared/presentation/bloc/subscription_purchase/subscription_purchase_state.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

extension ProductIdX on ProductId {
  int get level {
    switch (this) {
      case ProductId.basic:
        return 0;
      case ProductId.standard:
        return 1;
      case ProductId.plus:
        return 2;
      case ProductId.premium:
        return 3;
    }
  }

  String get displayTitle {
    switch (this) {
      case ProductId.basic:
        return 'Gói Basic';
      case ProductId.standard:
        return 'Gói Standard';
      case ProductId.plus:
        return 'Gói Plus';
      case ProductId.premium:
        return 'Gói Premium';
    }
  }

  String get subtitle {
    switch (this) {
      case ProductId.basic:
        return 'Phù hợp cho nhu cầu cơ bản';
      case ProductId.standard:
        return 'Hỗ trợ công việc hàng ngày';
      case ProductId.plus:
        return 'Hiệu quả hơn, kết nối tốt hơn';
      case ProductId.premium:
        return 'Không giới hạn, trải nghiệm tối ưu';
    }
  }

  // Giới hạn đơn hàng
  String get limitTitle {
    switch (this) {
      case ProductId.basic:
        return 'Tối đa 10 đơn / 1 lộ trình giao';
      case ProductId.standard:
        return 'Tối đa 30 đơn / 1 lộ trình giao';
      case ProductId.plus:
        return 'Tối đa 50 đơn / 1 lộ trình giao';
      case ProductId.premium:
        return 'Không giới hạn số lượng đơn hàng';
    }
  }

  String get limitSubtitle {
    switch (this) {
      case ProductId.basic:
        return 'Dành cho nhu cầu trải nghiệm';
      case ProductId.standard:
        return 'Phù hợp cho nhu cầu giao hàng cơ bản';
      case ProductId.plus:
        return 'Nâng cao hiệu suất';
      case ProductId.premium:
        return 'Dành cho nhu cầu lớn';
    }
  }

  IconData get limitIcon {
    switch (this) {
      case ProductId.basic:
      case ProductId.standard:
        return Icons.assignment_outlined;
      case ProductId.plus:
        return Icons.trending_up;
      case ProductId.premium:
        return Icons.all_inclusive;
    }
  }

  // Danh sách các tính năng đi kèm
  List<PlanFeature> get features {
    switch (this) {
      case ProductId.basic:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: 'Quét thông tin đơn hàng bằng AI',
            subtitle: 'Nhập liệu nhanh chóng chỉ bằng một lần chụp',
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: 'Nhập dữ liệu bằng JSON',
            subtitle: 'Linh hoạt và tiện lợi',
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: 'Lưu vị trí người nhận',
            subtitle: 'Lưu tọa độ chính xác cho các lần giao sau',
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),

          PlanFeature(
            icon: Icons.explore_outlined,
            title: 'Gợi ý vị trí thông minh',
            subtitle: 'Gợi ý tọa độ chuẩn từ cộng đồng tài xế đã giao',
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
        ];
      case ProductId.standard:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: 'Quét thông tin đơn hàng bằng AI',
            subtitle: 'Nhập liệu nhanh chóng chỉ bằng một lần chụp',
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: 'Nhập dữ liệu bằng JSON',
            subtitle: 'Linh hoạt và tiện lợi',
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: 'Lưu vị trí người nhận',
            subtitle: 'Lưu tọa độ chính xác cho các lần giao sau',
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: 'Gợi ý vị trí thông minh',
            subtitle: 'Gợi ý tọa độ chuẩn từ cộng đồng tài xế đã giao',
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: 'Hỗ trợ cơ bản',
            subtitle: 'Giải đáp trong giờ hành chính',
            iconColor: Colors.teal,
            bgColor: const Color(0xFFE0F2F1),
          ),
        ];
      case ProductId.plus:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: 'Quét thông tin đơn hàng bằng AI',
            subtitle: 'Nhập liệu nhanh chóng chỉ bằng một lần chụp',
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: 'Nhập dữ liệu bằng JSON',
            subtitle: 'Linh hoạt và tiện lợi',
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.location_on_outlined,
            title: 'Lấy chính xác vị trí người nhận',
            subtitle:
                'Yêu cầu khách định vị và chỉ đường dễ dàng và nhanh chóng',
            iconColor: Colors.green,
            bgColor: const Color(0xFFE8F5E9),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: 'Lưu vị trí người nhận',
            subtitle: 'Lưu tọa độ chính xác cho các lần giao sau',
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: 'Gợi ý vị trí thông minh',
            subtitle: 'Gợi ý tọa độ chuẩn từ cộng đồng tài xế đã giao',
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: 'Hỗ trợ ưu tiên 24/7',
            subtitle: 'Luôn sẵn sàng hỗ trợ bạn mọi lúc',
            iconColor: Colors.blueAccent,
            bgColor: const Color(0xFFE3F2FD),
          ),
        ];
      case ProductId.premium:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: 'Quét thông tin đơn hàng bằng AI',
            subtitle: 'Nhập liệu nhanh chóng chỉ bằng một lần chụp',
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: 'Nhập dữ liệu bằng JSON',
            subtitle: 'Linh hoạt và tiện lợi',
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.location_on_outlined,
            title: 'Lấy chính xác vị trí người nhận',
            subtitle:
                'Yêu cầu khách định vị và chỉ đường dễ dàng và nhanh chóng',
            iconColor: Colors.green,
            bgColor: const Color(0xFFE8F5E9),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: 'Lưu vị trí người nhận',
            subtitle: 'Lưu tọa độ chính xác cho các lần giao sau',
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: 'Gợi ý vị trí thông minh',
            subtitle: 'Gợi ý tọa độ chuẩn từ cộng đồng tài xế đã giao',
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: 'Hỗ trợ ưu tiên 24/7',
            subtitle: 'Đội ngũ hỗ trợ chuyên biệt, phản hồi nhanh nhất',
            iconColor: Colors.orange,
            bgColor: const Color(0xFFFFF3E0),
          ),
        ];
    }
  }
}

class PlanFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color bgColor;

  PlanFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.bgColor,
  });
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? activePlanId;
  late final GetCurrentPlanCubit _getCurrentPlanCubit;
  late final SubscriptionPurchaseCubit _subscriptionPurchaseCubit;

  final List<ProductId> _appPlans = [
    ProductId.basic,
    ProductId.standard,
    ProductId.plus,
    ProductId.premium,
  ];

  @override
  void initState() {
    super.initState();
    _subscriptionPurchaseCubit = di<SubscriptionPurchaseCubit>()..initialize();
    _getCurrentPlanCubit = di<GetCurrentPlanCubit>()..call();
  }

  @override
  void dispose() {
    _subscriptionPurchaseCubit.close();
    _getCurrentPlanCubit.close();
    super.dispose();
  }

  int get _activePlanLevel {
    final activeEnum = ProductId.values.firstWhere(
      (e) => e.value == activePlanId,
      orElse: () => ProductId.basic,
    );
    return activeEnum.level;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _subscriptionPurchaseCubit),
        BlocProvider.value(value: _getCurrentPlanCubit),
      ],
      child: BlocConsumer<GetCurrentPlanCubit, GetCurrentPlanState>(
        listener: (context, state) {
          if (state is GetCurrentPlanDone && mounted) {
            setState(() {
              activePlanId = state.subscription!.productId;
            });
          }
        },
        builder: (_, getCurrentPlanState) =>
            BlocConsumer<SubscriptionPurchaseCubit, SubscriptionPurchaseState>(
              listener: (context, state) {
                if (state.status == SubscriptionPurchaseStatus.success) {
                  _getCurrentPlanCubit.call();
                  AppDialogUtils.showSuccess(
                    context: context,
                    title: 'Thanh toán thành công!',
                  );
                } else if (state.status == SubscriptionPurchaseStatus.error) {
                  if (state.error is AppException &&
                      (state.error as AppException).code == 'PAYMENT_FAILED') {
                    AppDialogUtils.showError(
                      context: context,
                      title: 'Thanh toán thất bại!',
                    );
                  }
                }
              },
              builder: (context, state) {
                final priceMap = <String, String>{
                  ProductId.basic.value: '0đ/tháng',
                };
                for (var p in state.products) {
                  priceMap[p.id] = '${p.price}/tháng';
                }

                Widget body = Skeletonizer(
                  enabled:
                      state.status == SubscriptionPurchaseStatus.loading ||
                      getCurrentPlanState is GetCurrentPlanLoading,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00A651),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Nâng cấp gói để mở khóa tính năng nâng cao và tăng giới hạn đơn hàng cho mỗi lộ trình.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._appPlans.map((productEnum) {
                          final price = priceMap[productEnum.value] ?? '---';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildPlanCard(
                              productEnum: productEnum,
                              price: price,
                              context: context,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );

                if (getCurrentPlanState is GetCurrentPlanFailed) {
                  body = LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: SubscriptionError(
                              onRetry: () {
                                _getCurrentPlanCubit.call();
                                _subscriptionPurchaseCubit.initialize();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return Scaffold(
                  backgroundColor: const Color(0xFFF5F6F8),
                  appBar: AppBar(
                    backgroundColor: const Color(0xFF00A651),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    title: const Text(
                      'Chọn gói đăng ký',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  body: RefreshIndicator(
                    onRefresh: () async {
                      activePlanId = null;
                      await Future.wait([
                        _getCurrentPlanCubit.call(),
                        _subscriptionPurchaseCubit.initialize(),
                      ]);
                    },
                    child: body,
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildActionButton({
    required ProductId productEnum,
    required bool isActive,
    required BuildContext context,
  }) {
    final themeColor = PlanUiHelper.getPlanIconColor(productEnum.value);

    if (isActive && productEnum != ProductId.basic) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        child: const Text(
          'Huỷ gia hạn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (productEnum.level > _activePlanLevel &&
        productEnum != ProductId.basic) {
      return OutlinedButton(
        onPressed: () {
          final subscriptionPurchaseCubit = _subscriptionPurchaseCubit;
          final productDetails = subscriptionPurchaseCubit.state.products
              .where((product) => product.id == productEnum.value)
              .firstOrNull;
          if (productDetails != null) {
            subscriptionPurchaseCubit.buyProduct(productDetails);
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text(
                    'Không tìm thấy thông tin gói dịch vụ. Vui lòng tải lại trang!',
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: themeColor,
          side: BorderSide(color: themeColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        child: const Text(
          'Đăng ký ngay',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (productEnum != ProductId.basic) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Không khả dụng',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlanCard({
    required ProductId productEnum,
    required String price,
    required BuildContext context,
  }) {
    final bool isActive = activePlanId == productEnum.value;
    final themeColor = PlanUiHelper.getPlanIconColor(productEnum.value);
    final themeBgColor = PlanUiHelper.getPlanIconBgColor(productEnum.value);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? themeColor : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Title + Tag Subtitle + Price
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PlanUiHelper.getPlanIcon(productEnum.value),
                        color: themeColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productEnum.displayTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (productEnum.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                productEnum.subtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Hiển thị giá tiền nếu không active, hoặc căn chỉnh lề nếu active
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: themeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price,
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banner Giới hạn số lượng đơn hàng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeBgColor.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          productEnum.limitIcon,
                          color: themeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productEnum.limitTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              productEnum.limitSubtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Danh sách tính năng nổi bật
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Các tính năng nổi bật',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...productEnum.features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: feature.bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                feature.icon,
                                color: feature.iconColor,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                  Text(
                                    feature.subtitle,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Nút hành động góc dưới bên phải
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionButton(
                    productEnum: productEnum,
                    isActive: isActive,
                    context: context,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Marker/Badge "GÓI ĐANG SỬ DỤNG"
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GÓI ĐANG SỬ DỤNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.check_circle, color: Colors.white, size: 12),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
