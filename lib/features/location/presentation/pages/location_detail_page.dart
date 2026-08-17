import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/utils/external_url_util.dart';
import 'package:shipgo/core/widgets/image_slider.dart';
import 'package:shipgo/core/widgets/m3_map.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/location/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/delete_location/delete_location_cubic.dart';
import 'package:shipgo/features/location/presentation/bloc/delete_location/delete_location_state.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailPage extends StatefulWidget {
  const LocationDetailPage({super.key});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late BuildContext _locationPageContext;
  late bool _isLoadingImages;
  late LocationEntity _location;
  late List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = [];
    _isLoadingImages = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    _locationPageContext = extra['LocationPageContext'] as BuildContext;
    _location = extra['LocationData'] as LocationEntity;
    _getImageUrls(_location.media.map((e) => e.fileKey).toList());
  }

  void _getImageUrls(List<String> fileKeys) async {
    setState(() {
      _isLoadingImages = true;
    });
    final results = await Future.wait(
      _location.media.map((e) async {
        final dataState = await di<GetDownloadUrlUsecase>().call(
          params: GetDownloadUrlParams(fileKey: e.fileKey),
        );
        if (dataState is DataSuccess) {
          return dataState.data!;
        }
        return null;
      }),
    );
    setState(() {
      _imageUrls = results.nonNulls.toList();
      _isLoadingImages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
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
                    imageUrls: _imageUrls,
                    enableAutoScroll: false,
                    isLoading: _isLoadingImages,
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
                          _location.locationName.toUpperCase(),
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
                          _location.address,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                    value: _location.contactName,
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    label: AppStrings.lDPContactPhoneLabel.tr(),
                    value: _location.contactPhone,
                  ),
                  const SizedBox(height: 16),

                  // Hàng nút liên hệ (Gọi điện, Nhắn SMS, Zalo)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final dialUrl = ExternalUrlUtil.getDialUrl(
                              _location.contactPhone,
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
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                              phoneNumber: _location.contactPhone,
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
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                            final zaloUri = ExternalUrlUtil.getZaloUrl(
                              _location.contactPhone,
                            );
                            if (await canLaunchUrl(zaloUri)) {
                              await launchUrl(
                                zaloUri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppAssets.icZalo, width: 18),
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

                  // Khung Map
                  M3MapWidget(
                    mode: MapMode.view,
                    userAgentPackageName: Env.packageName,
                    center: LatLng(_location.location.y, _location.location.x),
                  ),

                  const SizedBox(height: 24),

                  // Nút Chỉnh sửa & Xóa địa điểm
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
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

                            showDialog(
                              context: context,
                              builder: (dialogContext) => BlocProvider<DeleteLocationCubic>(
                                create: (_) => di<DeleteLocationCubic>(),
                                child: BlocConsumer<DeleteLocationCubic, DeleteLocationState>(
                                  listener: (consumerContext, dialogState) {
                                    if (dialogState is DeleteLocationDone) {
                                      Navigator.of(consumerContext).pop();
                                      if (parentContext.mounted) {
                                        Navigator.of(parentContext).pop();
                                      }
                                      final extra =
                                          GoRouterState.of(parentContext).extra
                                              as Map<String, Object>;
                                      _locationPageContext
                                          .read<GetMyLocationsCubit>()
                                          .call(
                                            extra['GetMyLocationsParams']
                                                as GetMyLocationsParams,
                                          );
                                    }
                                  },
                                  builder: (consumerContext, dialogState) {
                                    final isLoading =
                                        dialogState is DeleteLocationLoading;

                                    return AlertDialog(
                                      title: Text(
                                        AppStrings.lDPDeleteLocationDialogTitle
                                            .tr(),
                                      ),
                                      content: Text(
                                        AppStrings
                                            .lDPDeleteLocationDialogContent
                                            .tr(),
                                      ),
                                      actions: [
                                        // Nút Hủy
                                        TextButton(
                                          onPressed: !isLoading
                                              ? () => Navigator.of(
                                                  consumerContext,
                                                ).pop()
                                              : null,
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.green,
                                          ),
                                          child: Text(
                                            AppStrings
                                                .lDPDeleteLocationDialogCancelBtnTitle
                                                .tr(),
                                          ),
                                        ),

                                        // Nút Đồng ý xóa
                                        TextButton(
                                          onPressed: !isLoading
                                              ? () {
                                                  // Chỉ gọi hàm xóa, KHÔNG pop() ở đây.
                                                  // Việc pop() sẽ do listener ở trên tự đảm nhận khi xóa thành công.
                                                  consumerContext
                                                      .read<
                                                        DeleteLocationCubic
                                                      >()
                                                      .call(_location.id);
                                                }
                                              : null, // Disable nút khi đang xóa
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.red,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  AppStrings
                                                      .lDPDeleteLocationDialogDeleteBtnTitle
                                                      .tr(),
                                                ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
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
