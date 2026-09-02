import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/core/security/token/domain/usecases/clear_token_usecase.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_state.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_cubit.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_state.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_loading_screen.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

enum MenuItem { plan, language, group, guide, signout }

class PersonPage extends StatelessWidget {
  const PersonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetProfileCubit>(
          create: (context) => di<GetProfileCubit>()..call(),
        ),
        BlocProvider<SignoutCubit>(create: (context) => di<SignoutCubit>()),
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
                title: const Text(
                  'Cá nhân',
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
                        _buildMenuList(
                          primaryColor: primaryColor,
                          context: context,
                        ),
                        const SizedBox(height: 24),
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
                    title: 'Đăng xuất thất bại!',
                    subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại.',
                  );
                }
              },
              builder: (context, state) => SmgoLoadingScreen(
                isLoading: state is SignoutLoading,
                title: 'Đang đăng xuất...',
                subtitle: 'Vui lòng chờ',
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
          Stack(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: profile?.avatarUrl != null
                      ? Image.network(
                          profile!.avatarUrl!,
                          fit: BoxFit.cover,
                          // Xử lý khi đường dẫn hỏng hoặc lỗi kết nối
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              AppAssets.defaultAvatar,
                              fit: BoxFit.cover,
                            );
                          },
                          // Khung hiển thị tạm trong lúc đang tải ảnh
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Image.asset(
                              AppAssets.defaultAvatar,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(AppAssets.defaultAvatar, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? '',
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
                        'ID: ${profile?.uuid ?? ''}',
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
                            const SnackBar(
                              content: Text('Đã sao chép ID!'),
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

  // Widget: Gói hiện tại
  Widget _buildSubscriptionCard(Color primaryColor) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gói hiện tại',
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
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
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
                          const Text(
                            'Gói Pro',
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
                              'Đang hoạt động',
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
                      const Text(
                        'Hiệu lực đến 20/09/2025',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              'Xem chi tiết',
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
          // Khung khuyến mại/Mua gói
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.card_giftcard, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bạn muốn trải nghiệm thêm nhiều tính năng?',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
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
                  child: const Text(
                    'Mua gói ngay',
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
    );
  }

  // Widget: Danh sách Menu bên dưới
  Widget _buildMenuList({
    required Color primaryColor,
    required BuildContext context,
  }) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'name': MenuItem.plan,
        'icon': Icons.shopping_bag_outlined,
        'title': 'Mua gói',
        'color': const Color(0xFFFEF3C7),
        'iconColor': Colors.orange,
      },
      {
        'name': MenuItem.language,
        'icon': Icons.language,
        'title': 'Ngôn ngữ',
        'trailingText': 'Tiếng Việt',
        'color': const Color(0xFFDCFCE7),
        'iconColor': primaryColor,
      },
      {
        'name': MenuItem.group,
        'icon': Icons.groups_outlined,
        'title': 'Tham gia cộng đồng SmGo',
        'color': const Color(0xFFE0F2FE),
        'iconColor': Colors.blue,
      },
      {
        'name': MenuItem.guide,
        'icon': Icons.menu_book_outlined,
        'title': 'Hướng dẫn sử dụng',
        'color': const Color(0xFFE0E7FF),
        'iconColor': Colors.indigo,
      },
      {
        'name': MenuItem.signout,
        'icon': Icons.logout,
        'title': 'Đăng xuất',
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
                      break;
                    case MenuItem.language:
                      break;
                    case MenuItem.group:
                      break;
                    case MenuItem.guide:
                      break;
                    case MenuItem.signout:
                      AppDialogUtils.showCustomDialog(
                        context: context,
                        title: 'Bạn có chắc chắn muốn đăng xuất tài khoản?',
                        iconData: Icons.logout,
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
}
