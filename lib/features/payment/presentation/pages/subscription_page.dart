import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/core/resources/app_strings.dart';
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
        return AppStrings.sPPBasicDisplayTitle.tr();
      case ProductId.standard:
        return AppStrings.sPPStandardDisplayTitle.tr();
      case ProductId.plus:
        return AppStrings.sPPPlusDisplayTitle.tr();
      case ProductId.premium:
        return AppStrings.sPPPremiumDisplayTitle.tr();
    }
  }

  String get subtitle {
    switch (this) {
      case ProductId.basic:
        return AppStrings.sPPBasicSubtitle.tr();
      case ProductId.standard:
        return AppStrings.sPPStandardSubtitle.tr();
      case ProductId.plus:
        return AppStrings.sPPPlusSubtitle.tr();
      case ProductId.premium:
        return AppStrings.sPPPremiumSubtitle.tr();
    }
  }

  // Giới hạn đơn hàng
  String get limitTitle {
    switch (this) {
      case ProductId.basic:
        return AppStrings.sPPBasicLimitTitle.tr();
      case ProductId.standard:
        return AppStrings.sPPStandardLimitTitle.tr();
      case ProductId.plus:
        return AppStrings.sPPPlusLimitTitle.tr();
      case ProductId.premium:
        return AppStrings.sPPPremiumLimitTitle.tr();
    }
  }

  String get limitSubtitle {
    switch (this) {
      case ProductId.basic:
        return AppStrings.sPPBasicLimitSubtitle.tr();
      case ProductId.standard:
        return AppStrings.sPPStandardLimitSubtitle.tr();
      case ProductId.plus:
        return AppStrings.sPPPlusLimitSubtitle.tr();
      case ProductId.premium:
        return AppStrings.sPPPremiumLimitSubtitle.tr();
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
            title: AppStrings.sPPBasicAiScanFeatureTitle.tr(),
            subtitle: AppStrings.sPPBasicAiScanFeatureSubtitle.tr(),
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: AppStrings.sPPBasicJsonInputFeatureTitle.tr(),
            subtitle: AppStrings.sPPBasicJsonInputFeatureSubtitle.tr(),
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: AppStrings.sPPBasicSaveLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPBasicSaveLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),

          PlanFeature(
            icon: Icons.explore_outlined,
            title: AppStrings.sPPBasicSmartLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPBasicSmartLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
        ];
      case ProductId.standard:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: AppStrings.sPPStandardAiScanFeatureTitle.tr(),
            subtitle: AppStrings.sPPStandardAiScanFeatureSubtitle.tr(),
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: AppStrings.sPPStandardJsonInputFeatureTitle.tr(),
            subtitle: AppStrings.sPPStandardJsonInputFeatureSubtitle.tr(),
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: AppStrings.sPPStandardSaveLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPStandardSaveLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: AppStrings.sPPStandardSmartLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPStandardSmartLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: AppStrings.sPPStandardBasicSupportFeatureTitle.tr(),
            subtitle: AppStrings.sPPStandardBasicSupportFeatureSubtitle.tr(),
            iconColor: Colors.teal,
            bgColor: const Color(0xFFE0F2F1),
          ),
        ];
      case ProductId.plus:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: AppStrings.sPPPlusAiScanFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusAiScanFeatureSubtitle.tr(),
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: AppStrings.sPPPlusJsonInputFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusJsonInputFeatureSubtitle.tr(),
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.location_on_outlined,
            title: AppStrings.sPPPlusPreciseLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusPreciseLocationFeatureSubtitle.tr(),
            iconColor: Colors.green,
            bgColor: const Color(0xFFE8F5E9),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: AppStrings.sPPPlusSaveLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusSaveLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: AppStrings.sPPPlusSmartLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusSmartLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: AppStrings.sPPPlusPrioritySupportFeatureTitle.tr(),
            subtitle: AppStrings.sPPPlusPrioritySupportFeatureSubtitle.tr(),
            iconColor: Colors.blueAccent,
            bgColor: const Color(0xFFE3F2FD),
          ),
        ];
      case ProductId.premium:
        return [
          PlanFeature(
            icon: Icons.auto_awesome,
            title: AppStrings.sPPPremiumAiScanFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumAiScanFeatureSubtitle.tr(),
            iconColor: Colors.purple,
            bgColor: const Color(0xFFF3E5F5),
          ),
          PlanFeature(
            icon: Icons.insert_drive_file_outlined,
            title: AppStrings.sPPPremiumJsonInputFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumJsonInputFeatureSubtitle.tr(),
            iconColor: Colors.blue,
            bgColor: const Color(0xFFE3F2FD),
          ),
          PlanFeature(
            icon: Icons.location_on_outlined,
            title: AppStrings.sPPPremiumPreciseLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumPreciseLocationFeatureSubtitle.tr(),
            iconColor: Colors.green,
            bgColor: const Color(0xFFE8F5E9),
          ),
          PlanFeature(
            icon: Icons.bookmark_added_outlined,
            title: AppStrings.sPPPremiumSaveLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumSaveLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFF00ACC1),
            bgColor: const Color(0xFFE0F7FA),
          ),
          PlanFeature(
            icon: Icons.explore_outlined,
            title: AppStrings.sPPPremiumSmartLocationFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumSmartLocationFeatureSubtitle.tr(),
            iconColor: const Color(0xFFFB8C00),
            bgColor: const Color(0xFFFFE0B2),
          ),
          PlanFeature(
            icon: Icons.headset_mic_outlined,
            title: AppStrings.sPPPremiumPrioritySupportFeatureTitle.tr(),
            subtitle: AppStrings.sPPPremiumPrioritySupportFeatureSubtitle.tr(),
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
                    title: AppStrings.sPPPaymentSuccessTitle.tr(),
                  );
                } else if (state.status == SubscriptionPurchaseStatus.error) {
                  if (state.error is AppException &&
                      (state.error as AppException).code == 'PAYMENT_FAILED') {
                    AppDialogUtils.showError(
                      context: context,
                      title: AppStrings.sPPPaymentFailedTitle.tr(),
                    );
                  }
                }
              },
              builder: (context, state) {
                final priceMap = <String, String>{
                  ProductId.basic.value: AppStrings.sPPBasicPriceContent.tr(),
                };
                for (var p in state.products) {
                  priceMap[p.id] = AppStrings.sPPPriceContent.tr(
                    namedArgs: {'price': p.price},
                  );
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
                              Expanded(
                                child: Text(
                                  AppStrings.sPPUpgradePlanContent.tr(),
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
                    title: Text(
                      AppStrings.sPPUpgradePlanTitle.tr(),
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
        child: Text(
          AppStrings.sPPCancelRenewalButtonLabel.tr(),
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
                  content: Text(AppStrings.sPPProductNotFoundContent.tr()),
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
        child: Text(
          AppStrings.sPPSubscribeNowButtonLabel.tr(),
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
        child: Text(
          AppStrings.sPPUnavailableButtonLabel.tr(),
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
                    Text(
                      AppStrings.sPPFeaturedFeaturesTitle.tr(),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.sPPActivePlanBadgeLabel.tr(),
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
