import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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

/// Extension chứa toàn bộ UI Config & Text Localized của các gói
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
        return 'Tối ưu cho nhu cầu vừa phải';
      case ProductId.plus:
        return 'Đầy đủ tính năng, hiệu quả tối đa';
      case ProductId.premium:
        return 'Không giới hạn, không ràng buộc';
    }
  }

  String get descriptionHtml {
    switch (this) {
      case ProductId.basic:
        return '''
          <p style="margin:0; padding:0;">Tối đa 10 đơn / 1 lộ trình giao</p>
          <p style="margin:4px 0 0 0; padding:0;">Hạn chế sử dụng tính năng</p>
          <p style="margin:4px 0 0 0; padding:0;">Hỗ trợ cơ bản</p>
        ''';
      case ProductId.standard:
        return '''
          <p style="margin:0; padding:0;">Tối đa 25 đơn / 1 lộ trình giao</p>
          <p style="margin:4px 0 0 0; padding:0;">Đầy đủ tất cả tính năng cao cấp</p>
          <p style="margin:4px 0 0 0; padding:0;">Hỗ trợ ưu tiên</p>
        ''';
      case ProductId.plus:
        return '''
          <p style="margin:0; padding:0;">Tối đa 50 đơn / 1 lộ trình giao</p>
          <p style="margin:4px 0 0 0; padding:0;">Đầy đủ tất cả tính năng cao cấp</p>
          <p style="margin:4px 0 0 0; padding:0;">Hỗ trợ 24/7 qua Hotline</p>
        ''';
      case ProductId.premium:
        return '''
          <p style="margin:0; padding:0;">Không giới hạn số lượng đơn hàng</p>
          <p style="margin:4px 0 0 0; padding:0;">Đầy đủ tất cả tính năng cao cấp</p>
          <p style="margin:4px 0 0 0; padding:0;">Quản lý riêng & Hỗ trợ VIP 1-1</p>
        ''';
    }
  }
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String activePlanId = ProductId.basic.value;
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
    if (isActive && productEnum != ProductId.basic) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          foregroundColor: const Color(0xFF00A651),
          side: const BorderSide(color: Color(0xFF00A651)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          'Hiện không khả dụng',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildPlanCard({
    required ProductId productEnum,
    required String price,
    required BuildContext context,
  }) {
    final bool isActive = activePlanId == productEnum.value;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF00A651) : Colors.transparent,
              width: isActive ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PlanUiHelper.getPlanIconBgColor(productEnum.value),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PlanUiHelper.getPlanIcon(productEnum.value),
                      color: PlanUiHelper.getPlanIconColor(productEnum.value),
                      size: 24,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (productEnum.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            productEnum.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF00A651),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HtmlWidget(
                productEnum.descriptionHtml,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF333333),
                ),
                customStylesBuilder: (element) {
                  if (element.localName == 'body') {
                    return {'margin': '0', 'padding': '0'};
                  }
                  if (element.localName == 'ul') {
                    return {'margin': '0', 'padding-left': '16px'};
                  }
                  if (element.localName == 'li') {
                    return {'margin-bottom': '4px'};
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: _buildActionButton(
                  productEnum: productEnum,
                  isActive: isActive,
                  context: context,
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF00A651),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GÓI ĐANG SỬ DỤNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.check_circle, color: Colors.white, size: 12),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
