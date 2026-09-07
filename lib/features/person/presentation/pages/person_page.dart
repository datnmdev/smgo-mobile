import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/localization/presentation/bloc/get_locale/get_locale_cubit.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_cubit.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_state.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/core/security/token/domain/usecases/clear_token_usecase.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/person/domain/entities/language_entity.dart';
import 'package:smgo/features/person/presentation/widgets/language_bottom_sheet.dart';
import 'package:smgo/features/person/presentation/widgets/premium_banner_card.dart';
import 'package:smgo/features/person/presentation/widgets/smgo_community_bottom_sheet.dart';
import 'package:smgo/features/person/presentation/widgets/update_profile_bottom_sheet.dart';
import 'package:smgo/shared/helpers/plan_ui_helper.dart';
import 'package:smgo/features/person/presentation/widgets/plan_detail_bottom_sheet.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_state.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_state.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_cubit.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_state.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_loading_screen.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:smgo/shared/utils/app_url_utils.dart';

enum MenuItem { plan, language, group, guide, signout }

class PersonPage extends StatelessWidget {
  const PersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetProfileCubit>(
          create: (context) => di<GetProfileCubit>()..call(),
        ),
        BlocProvider<SignoutCubit>(create: (context) => di<SignoutCubit>()),
        BlocProvider<GetCurrentPlanCubit>(
          create: (context) => di<GetCurrentPlanCubit>()..call(),
        ),
        BlocProvider<GetLocaleCubit>(
          create: (context) => di<GetLocaleCubit>()..call(),
        ),
        BlocProvider<SetLocaleCubit>(create: (context) => di<SetLocaleCubit>()),
      ],
      child: BlocBuilder<GetProfileCubit, GetProfileState>(
        builder: (context, state) => Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAF8),
              appBar: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  AppStrings.pPAppBarTitle.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await context.read<GetProfileCubit>().call();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Skeletonizer(
                    enabled: state is GetProfileLoading,
                    child: Column(
                      children: [
                        // Thẻ Thông tin cá nhân
                        _buildProfileCard(
                          primaryColor: primaryColor,
                          profile: state.profile,
                          context: context,
                        ),
                        const SizedBox(height: 16),

                        // Thẻ Gói hiện tại
                        _buildSubscriptionCard(primaryColor),
                        const SizedBox(height: 16),

                        // Danh sách Menu
                        BlocConsumer<SetLocaleCubit, SetLocaleState>(
                          listener: (context, state) async {
                            final getLocaleCubit = context
                                .read<GetLocaleCubit>();
                            if (state is SetLocaleDone) {
                              await getLocaleCubit.call();
                              if (!context.mounted) {
                                return;
                              }
                              await context.setLocale(
                                getLocaleCubit.state.locale ??
                                    Locale('vi', 'VN'),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              context.pop();
                              await Restart.restartApp();
                            } else if (state is SetLocaleFailed) {
                              AppDialogUtils.showError(
                                context: context,
                                title: AppStrings.pPChangeLanguageFailedTitle
                                    .tr(),
                                subtitle: AppStrings
                                    .pPChangeLanguageFailedSubtitle
                                    .tr(),
                              );
                            }
                          },
                          builder: (context, state) => _buildMenuList(
                            primaryColor: primaryColor,
                            context: context,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Loadings
            BlocConsumer<SignoutCubit, SignoutState>(
              listener: (context, state) async {
                if (state is SignoutDone) {
                  await di<ClearTokenUsecase>().call(params: NoParams());
                  if (!context.mounted) {
                    return;
                  }
                  context.goNamed(AppRouteNames.onboarding);
                } else if (state is SignoutFailed) {
                  AppDialogUtils.showError(
                    context: context,
                    title: AppStrings.pPSignoutFailedTitle.tr(),
                    subtitle: AppStrings.pPSignoutFailedSubtitle.tr(),
                  );
                }
              },
              builder: (context, state) => SmgoLoadingScreen(
                isLoading: state is SignoutLoading,
                title: AppStrings.pPSignoutLoadingTitle.tr(),
                subtitle: AppStrings.pPSignoutLoadingSubtitle.tr(),
                icon: Icon(
                  Icons.logout_outlined,
                  color: AppColors.primary,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Thông tin người dùng
  Widget _buildProfileCard({
    required Color primaryColor,
    required UserEntity? profile,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          buildAvatarWidget(
            avatarUrl: profile?.avatarUrl,
            defaultAvatarAsset: AppAssets.defaultAvatar,
            primaryColor: primaryColor,
            editTap: () => _showUpdateProfileBottomSheet(context),
            size: 80,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? '---',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        AppStrings.pPUserIdLabel.tr(
                          namedArgs: {'uuid': profile?.uuid ?? '---'},
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      // constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(8),
                      onPressed: () async {
                        final uuid = profile?.uuid;
                        if (uuid == null || uuid.isEmpty) return;

                        await Clipboard.setData(ClipboardData(text: uuid));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppStrings.pPCopyUserIdSuccessMessage.tr(),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatarWidget({
    required String? avatarUrl,
    required String defaultAvatarAsset,
    required Color primaryColor,
    required VoidCallback editTap,
    double size = 80,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 1. Khung hiển thị ảnh Avatar
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      // Trạng thái bị lỗi (mạng hỏng, link chết, 404)
                      errorWidget: (context, url, error) =>
                          Image.asset(defaultAvatarAsset, fit: BoxFit.cover),
                    )
                  : Image.asset(defaultAvatarAsset, fit: BoxFit.cover),
            ),
          ),

          // 2. Nút chỉnh sửa (Edit Button)
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: editTap,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 14,
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

  // Widget: Gói hiện tại
  Widget _buildSubscriptionCard(Color primaryColor) {
    return BlocBuilder<GetCurrentPlanCubit, GetCurrentPlanState>(
      builder: (context, state) {
        if (state is GetCurrentPlanFailed) {
          return SizedBox();
        }
        final currentPlan = state.subscription;
        return Skeletonizer(
          enabled: state is GetCurrentPlanLoading,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  AppStrings.pPCurrentPlanTitle.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                // Khung thông tin gói Pro
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F9F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2F0E6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PlanUiHelper.getPlanIconBgColor(
                            currentPlan?.productId,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          PlanUiHelper.getPlanIcon(currentPlan?.productId),
                          color: PlanUiHelper.getPlanIconColor(
                            currentPlan?.productId,
                          ),
                          size: 24,
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
                                Text(
                                  PlanUiHelper.getPlanName(
                                    currentPlan?.productId,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    PlanUiHelper.getStatusName(
                                      currentPlan?.status,
                                    ),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentPlan != null
                                  ? (currentPlan.productId ==
                                            ProductId.basic.value
                                        ? AppStrings.pPUnlimitedDuration.tr()
                                        : AppStrings.pPPlanExpiresAtContent.tr(
                                            namedArgs: {
                                              'date': DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(currentPlan.expiresAt!),
                                            },
                                          ))
                                  : '---',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                _showPackageDetailBottomSheet(
                                  context: context,
                                  currentPlan: currentPlan,
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    AppStrings.pPViewDetailLabel.tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (currentPlan?.productId == ProductId.premium.value)
                  PremiumBannerCard()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.pPUpgradePlanSuggestionContent.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.pushNamed(AppRouteNames.subscription);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppStrings.pPBuyPlanNowButtonLabel.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hiển thị bottom sheet chi tiết gói
  void _showPackageDetailBottomSheet({
    required BuildContext context,
    required SubscriptionEntity? currentPlan,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanDetailBottomSheet(currentPlan: currentPlan),
    );
  }

  Widget _buildMenuList({
    required Color primaryColor,
    required BuildContext context,
  }) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'name': MenuItem.plan,
        'icon': Icons.shopping_bag_outlined,
        'title': AppStrings.pPMenuPlanTitle.tr(),
        'color': const Color(0xFFFEF3C7),
        'iconColor': Colors.orange,
      },
      {
        'name': MenuItem.language,
        'icon': Icons.language,
        'title': AppStrings.pPMenuLanguageTitle.tr(),
        'trailingText':
            appLanguageNativeNameMap[context
                    .read<GetLocaleCubit>()
                    .state
                    .locale
                    ?.languageCode ??
                'vi'],
        'color': const Color(0xFFDCFCE7),
        'iconColor': primaryColor,
      },
      {
        'name': MenuItem.group,
        'icon': Icons.groups_outlined,
        'title': AppStrings.pPMenuGroupTitle.tr(),
        'color': const Color(0xFFE0F2FE),
        'iconColor': Colors.blue,
      },
      {
        'name': MenuItem.guide,
        'icon': Icons.menu_book_outlined,
        'title': AppStrings.pPMenuGuideTitle.tr(),
        'color': const Color(0xFFE0E7FF),
        'iconColor': Colors.indigo,
      },
      {
        'name': MenuItem.signout,
        'icon': Icons.logout,
        'title': AppStrings.pPMenuSignoutTitle.tr(),
        'color': const Color(0xFFFEE2E2),
        'iconColor': Colors.red,
      },
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withAlpha((0.03 * 255).round()),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'], color: item['iconColor'], size: 20),
                ),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item['trailingText'] != null)
                      Text(
                        item['trailingText'],
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {
                  switch (item['name']) {
                    case MenuItem.plan:
                      context.pushNamed(AppRouteNames.subscription);
                      break;
                    case MenuItem.language:
                      _showLanguageBottomSheet(context: context);
                      break;
                    case MenuItem.group:
                      _showSmGoCommunityBottomSheet(context: context);
                      break;
                    case MenuItem.guide:
                      AppUrlUtils.launchLink(
                        'https://zalo.me/g/2367ucr5janxotvrrhpt',
                      );
                      break;
                    case MenuItem.signout:
                      AppDialogUtils.showCustomDialog(
                        context: context,
                        title: AppStrings.pPSignoutConfirmDialogTitle.tr(),
                        iconData: Icons.logout,
                        actions: [
                          SmgoButton(
                            isOutlined: true,
                            text: AppStrings.pPSignoutCancelButtonLabel.tr(),
                            primaryColor: AppColors.primary,
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          SmgoButton(
                            primaryColor: AppColors.primary,
                            text: AppStrings.pPSignoutConfirmButtonLabel.tr(),
                            onPressed: () {
                              context.read<SignoutCubit>().call();
                              context.pop();
                            },
                          ),
                        ],
                      );
                      break;
                    default:
                      throw Exception(
                        'Menu item name does not match any value.',
                      );
                  }
                },
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _showUpdateProfileBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.68,
        child: UpdateProfileBottomSheet(
          profile: context.read<GetProfileCubit>().state.profile,
          context: context,
        ),
      ),
    );
  }

  // Hàm tiện ích để gọi BottomSheet ở bất kỳ đâu
  void _showLanguageBottomSheet({required BuildContext context}) {
    final getLocaleCubit = context.read<GetLocaleCubit>();
    final setLocaleCubit = context.read<SetLocaleCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getLocaleCubit),
            BlocProvider.value(value: setLocaleCubit),
          ],
          child: BlocBuilder<SetLocaleCubit, SetLocaleState>(
            builder: (_, state) => LanguageBottomSheet(
              isSubmitting: state is SetLocaleLoading,
              selectedCode: getLocaleCubit.state.locale?.languageCode ?? 'vi',
              onSelected: (language) {
                setLocaleCubit.call(
                  locale: Locale(language.code, language.countryCode),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Tuỳ chọn cộng đồng SmGo
  void _showSmGoCommunityBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SmGoCommunityBottomSheet(),
    );
  }
}
