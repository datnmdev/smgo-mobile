import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/utils/external_url_util.dart';
import 'package:smgo/shared/presentation/widgets/image_slider.dart';
import 'package:smgo/shared/presentation/widgets/m3_map.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/shared/domain/entities/location_entity.dart';
import 'package:smgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_state.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_state.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailPage extends StatefulWidget {
  const LocationDetailPage({super.key});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  LocationEntity? location;

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    location = location ?? extra['LocationData'] as LocationEntity;
    final getMyLocationsCubitInLP =
        extra['GetMyLocationsCubitInLP'] as GetMyLocationsCubit;
    final getMyLocationsParamsInLP =
        extra['GetMyLocationsParamsInLP'] as GetMyLocationsParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetMyLocationsCubit>(
          create: (context) => di<GetMyLocationsCubit>()
            ..getMyLocationsUsecase.call(
              params: GetMyLocationsParams(
                pageNumber: 1,
                pageSize: 1,
                id: location!.id,
              ),
            ),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
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
            AppStrings.lDPTitle.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [],
        ),
        body: BlocConsumer<GetMyLocationsCubit, GetMyLocationsState>(
          listener: (context, state) {
            if (state is GetMyLocationsDone) {
              getMyLocationsCubitInLP.call(getMyLocationsParamsInLP);

              setState(() {
                location = state.data!.data[0];
              });
            }
          },
          builder: (context, state) => RefreshIndicator(
            onRefresh: () async {
              await context.read<GetMyLocationsCubit>().call(
                GetMyLocationsParams(
                  pageNumber: 1,
                  pageSize: 1,
                  id: location!.id,
                ),
              );
            },
            child: BlocBuilder<GetMyLocationsCubit, GetMyLocationsState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Image với hiệu ứng nền xanh phía sau
                      Stack(
                        children: [
                          Container(
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ImageSlider(
                              imageUrls: location!.media
                                  .map((e) => e.url)
                                  .toList(),
                              enableAutoScroll: false,
                            ),
                          ),
                        ],
                      ),

                      // Nôi dung chi tiết
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên quán & Đánh giá
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    location!.locationName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
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
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '4.6',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Địa chỉ
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location!.address,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Thông tin liên hệ
                            Text(
                              AppStrings.lDPContactInfoLabel.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              icon: Icons.person_outline,
                              label: AppStrings.lDPContactNameLabel.tr(),
                              value: location!.contactName,
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              icon: Icons.phone_outlined,
                              label: AppStrings.lDPContactPhoneLabel.tr(),
                              value: location!.contactPhone,
                            ),
                            const SizedBox(height: 16),

                            // Hàng nút liên hệ (Gọi điện, Nhắn SMS, Zalo)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final dialUrl =
                                          ExternalUrlUtil.getDialUrl(
                                            location!.contactPhone,
                                          );
                                      if (await canLaunchUrl(dialUrl)) {
                                        await launchUrl(dialUrl);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.phone,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      AppStrings.lDPCallButtonTitle.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final smsUrl = ExternalUrlUtil.getSmsUrl(
                                        phoneNumber: location!.contactPhone,
                                        message: '',
                                      );
                                      if (await canLaunchUrl(smsUrl)) {
                                        await launchUrl(smsUrl);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      AppStrings.lDPSMSButtonTitle.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.1,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final zaloUri =
                                          ExternalUrlUtil.getZaloUrl(
                                            location!.contactPhone,
                                          );
                                      if (await canLaunchUrl(zaloUri)) {
                                        await launchUrl(
                                          zaloUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppAssets.icZalo,
                                          width: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppStrings.lDPZaloButtonTitle.tr(),
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Vị trí & Bản đồ
                            Text(
                              AppStrings.lDPLocationMapLabel.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Điều hướng
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildNavigationItem(
                                  title: AppStrings.lDPGoogleMapsNavigationTitle
                                      .tr(),
                                  subtitle: AppStrings
                                      .lDPGoogleMapsNavigationSubtitle
                                      .tr(),
                                  icon: Image.asset(
                                    AppAssets.icGoogleMaps,
                                    width: 32,
                                    height: 32,
                                  ),
                                  onTap: () async {
                                    final googleMapDirectionsUri =
                                        ExternalUrlUtil.getGoogleMapsDirectionsUri(
                                          destinationLat: location!.location.y,
                                          destinationLng: location!.location.x,
                                        );

                                    if (await canLaunchUrl(
                                      googleMapDirectionsUri,
                                    )) {
                                      await launchUrl(
                                        googleMapDirectionsUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 8),

                                _buildNavigationItem(
                                  title: AppStrings.lDPAppMapNavigationTitle
                                      .tr(),
                                  subtitle: AppStrings
                                      .lDPAppMapNavigationSubtitle
                                      .tr(),
                                  icon: Image.asset(
                                    AppAssets.logo,
                                    width: 32,
                                    height: 32,
                                  ),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings.lDPAppMapDevelopingMessage
                                              .tr(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Khung Map
                            M3MapWidget(
                              mode: MapMode.view,
                              userAgentPackageName: Env.packageName,
                              selectLocationError: AppStrings
                                  .m3MSelectLocationError
                                  .tr(),
                              cannotGetLocationError: AppStrings
                                  .m3MCannotGetLocationError
                                  .tr(),
                              mapTemplateUrl: Env.mapTemplateUrl,
                              center: LatLng(
                                location!.location.y,
                                location!.location.x,
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
        ),
        bottomNavigationBar: BlocBuilder<GetMyLocationsCubit, GetMyLocationsState>(
          builder: (context, state) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        AppRouteNames.updateLocation,
                        pathParameters: {'id': location!.id},
                        extra: <String, Object>{
                          'LocationData': location!,
                          'GetMyLocationsCubitInLDP': context
                              .read<GetMyLocationsCubit>(),
                          'GetMyLocationsParamsInLDP': GetMyLocationsParams(
                            pageNumber: 1,
                            pageSize: 1,
                            id: location!.id,
                          ),
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      AppStrings.lDPEditButtonTitle.tr(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Lưu lại context của màn hình chính
                      final parentContext = context;
                      AppDialogUtils.showCustomDialog(
                        context: context,
                        title: AppStrings.lDPDeleteLocationDialogTitle.tr(),
                        subtitle: AppStrings.lDPDeleteLocationDialogContent
                            .tr(),
                        barrierDismissible: false,
                        actions: [
                          BlocProvider<DeleteLocationsCubit>(
                            create: (_) => di<DeleteLocationsCubit>(),
                            child: BlocConsumer<DeleteLocationsCubit, DeleteLocationsState>(
                              listener: (consumerContext, dialogState) {
                                if (dialogState is DeleteLocationsDone) {
                                  // Đóng dialog
                                  consumerContext.pop();

                                  // Đóng màn hình hiện tại
                                  if (parentContext.mounted) {
                                    parentContext.pop();
                                  }

                                  // Reload danh sách địa điểm
                                  getMyLocationsCubitInLP.call(
                                    getMyLocationsParamsInLP,
                                  );

                                  // Thông báo thành công
                                  AppDialogUtils.showSuccess(
                                    context: context,
                                    title: AppStrings
                                        .lDPDeleteLocationSuccessTitle
                                        .tr(),
                                  );
                                } else if (dialogState
                                    is DeleteLocationsFailed) {
                                  AppDialogUtils.showError(
                                    context: context,
                                    title: AppStrings
                                        .lDPDeleteLocationFailedTitle
                                        .tr(),
                                    subtitle: AppStrings
                                        .lDPDeleteLocationFailedContent
                                        .tr(),
                                  );
                                }
                              },
                              builder: (consumerContext, dialogState) {
                                final isLoading =
                                    dialogState is DeleteLocationsLoading;

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
                                              .lDPDeleteLocationDialogCancelBtnTitle
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
                                                .read<DeleteLocationsCubit>()
                                                .call(
                                                  locationIds: [location!.id],
                                                );
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
                                                      .lDPDeleteLocationDialogDeleteBtnTitle
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
                      color: Colors.red,
                    ),
                    label: Text(
                      AppStrings.lDPDeleteButtonTitle.tr(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  static Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(text: '$label '),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
