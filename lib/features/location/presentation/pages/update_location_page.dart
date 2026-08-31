import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/utils/app_dialog_utils.dart';
import 'package:shipgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:shipgo/shared/presentation/widgets/m3_image_picker.dart';
import 'package:shipgo/shared/presentation/widgets/m3_map.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/update_location_form/update_location_form_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/update_location_form/update_location_form_state.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_phone.dart';

class UpdateLocationPage extends StatefulWidget {
  const UpdateLocationPage({super.key});

  @override
  State<UpdateLocationPage> createState() => _UpdateLocationPageState();
}

class _UpdateLocationPageState extends State<UpdateLocationPage> {
  late LocationEntity locationData;
  late TextEditingController locationNameController;
  late TextEditingController contactNameController;
  late TextEditingController contactPhoneController;
  late TextEditingController addressController;
  late TextEditingController noteController;
  bool _isInitialized = false;

  @override
  void dispose() {
    super.dispose();
    locationNameController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    addressController.dispose();
    noteController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final extra = GoRouterState.of(context).extra as Map<String, Object>;
      locationData = extra['LocationData'] as LocationEntity;
      locationNameController = TextEditingController(
        text: locationData.locationName,
      );
      contactNameController = TextEditingController(
        text: locationData.contactName,
      );
      contactPhoneController = TextEditingController(
        text: locationData.contactPhone,
      );
      addressController = TextEditingController(text: locationData.address);
      noteController = TextEditingController(text: locationData.note ?? '');
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final getMyLocationsCubitInLDP =
        extra['GetMyLocationsCubitInLDP'] as GetMyLocationsCubit;
    final getMyLocationsParamsInLDP =
        extra['GetMyLocationsParamsInLDP'] as GetMyLocationsParams;

    return BlocProvider<UpdateLocationFormCubit>(
      create: (context) {
        final cubit = di<UpdateLocationFormCubit>(param1: locationData.id);
        cubit.locationNameChanged(locationData.locationName);
        cubit.contactNameChanged(locationData.contactName);
        cubit.contactPhoneChanged(locationData.contactPhone);
        cubit.addressChanged(locationData.address);
        cubit.noteChanged(locationData.note ?? '');
        cubit.locationChanged(
          LatLng(locationData.location.y, locationData.location.x),
        );
        cubit.mediaIdsChanged(locationData.media.map((e) => e.id).toList());
        return cubit;
      },

      child: BlocConsumer<UpdateLocationFormCubit, UpdateLocationFormState>(
        listener: (context, state) {
          if (state is UpdateLocationFormDone) {
            getMyLocationsCubitInLDP.call(getMyLocationsParamsInLDP);
            AppDialogUtils.showSuccess(
              context: context,
              title: 'Cập nhật địa điểm thành công!',
              subtitle: 'Thông tin địa điểm đã được lưu.',
            );
          } else if (state is UpdateLocationFormFailed) {
            AppDialogUtils.showError(
              context: context,
              title: 'Cập nhật địa điểm thất bại!',
              subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại sau.',
            );
          }
        },
        builder: (context, state) => Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.8 * 255).round()),
                      offset: Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: statusBarHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios_new, size: 16,),
                              color: Colors.white,
                              onPressed: () {
                                context.pop();
                              },
                            ),
                            SizedBox(width: 12),
                            Text(
                              AppStrings.uLPPageTitle.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),

                        if (state is UpdateLocationFormLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              context.read<UpdateLocationFormCubit>().submit();
                            },
                            child: Text(
                              AppStrings.uLPSaveButtonTitle.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thông tin chính
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              AppStrings.uLPPrimaryInfoLabel.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                // Tên địa điểm
                                Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => context
                                          .read<UpdateLocationFormCubit>()
                                          .locationNameChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      controller: locationNameController,
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .uLPLocationNameFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .uLPLocationNameFieldHintText
                                            .tr(),
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.locationName.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText: AppStrings
                                            .uLPLocationNameFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                // Tên người liên hệ
                                Column(
                                  children: [
                                    TextField(
                                      controller: contactNameController,
                                      onChanged: (value) => context
                                          .read<UpdateLocationFormCubit>()
                                          .contactNameChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .uLPContactNameFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .uLPContactNameFieldHintText
                                            .tr(),
                                        prefixIcon: Icon(Icons.person_outline),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.contactName.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText: AppStrings
                                            .uLPContactNameFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                // Số điện thoại liên lạc
                                Column(
                                  children: [
                                    TextField(
                                      controller: contactPhoneController,
                                      onChanged: (value) => context
                                          .read<UpdateLocationFormCubit>()
                                          .contactPhoneChanged(value),
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .uLPContactPhoneFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .uLPContactPhoneFieldHintText
                                            .tr(),
                                        prefixIcon: Icon(
                                          Icons.phone_android_outlined,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.contactPhone.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText:
                                            state
                                                    .contactPhone
                                                    .displayError!
                                                    .name ==
                                                ContactPhoneValidationError
                                                    .empty
                                                    .name
                                            ? AppStrings
                                                  .uLPContactPhoneFieldEmptyError
                                                  .tr()
                                            : AppStrings
                                                  .uLPContactPhoneFieldInvalidError
                                                  .tr(),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        // Vị trí
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vị trí',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                // Địa chỉ
                                Column(
                                  children: [
                                    TextField(
                                      controller: addressController,
                                      onChanged: (value) => context
                                          .read<UpdateLocationFormCubit>()
                                          .addressChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .uLPAddressFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .uLPAddressFieldHintText
                                            .tr(),
                                        prefixIcon: Icon(Icons.home_outlined),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.address.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText: AppStrings
                                            .uLPAddressFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                Column(
                                  children: [
                                    M3MapWidget(
                                      userAgentPackageName: Env.packageName,
                                      selectLocationError: AppStrings
                                          .m3MSelectLocationError
                                          .tr(),
                                      cannotGetLocationError: AppStrings
                                          .m3MCannotGetLocationError
                                          .tr(),
                                      mapTemplateUrl: Env.mapTemplateUrl,
                                      address: state.address.value,
                                      center: state.location.value != null
                                          ? LatLng(
                                              state.location.value!.y,
                                              state.location.value!.x,
                                            )
                                          : LatLng(
                                              locationData.location.y,
                                              locationData.location.x,
                                            ),
                                      onLocationSelected: (value) {
                                        context
                                            .read<UpdateLocationFormCubit>()
                                            .locationChanged(value);
                                      },
                                    ),
                                    if (state.location.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText: AppStrings
                                            .uLPLocationFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Thông tin bổ sung
                        SizedBox(height: 32),
                        // Vị trí
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.uLPSecondaryInfoLabel.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ghi chú
                                TextField(
                                  controller: noteController,
                                  onChanged: (value) => context
                                      .read<UpdateLocationFormCubit>()
                                      .noteChanged(value),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  minLines: 1,
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: AppStrings.uLPNoteFieldLabel
                                        .tr(),
                                    hintText: AppStrings.uLPNoteFieldHintText
                                        .tr(),
                                    prefixIcon: const Icon(
                                      Icons.note_alt_outlined,
                                    ),
                                    alignLabelWithHint: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.uLPAttachedImageLabel.tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    M3ImagePickerGrid(
                                      initialImages: locationData.media
                                          .map(
                                            (e) => GridImageItem(
                                              id: e.id,
                                              path: e.url,
                                            ),
                                          )
                                          .toList(),
                                      takeNewPhotoTitle: AppStrings
                                          .m3IPGTakeNewPhotoTitle
                                          .tr(),
                                      selectFromLibrary: AppStrings
                                          .m3IPGSelectFromLibrary
                                          .tr(),
                                      cameraTitle: AppStrings.m3IPGCameraTitle
                                          .tr(),
                                      imageLibraryTitle: AppStrings
                                          .m3IPGImageLibraryTitle
                                          .tr(),
                                      cancelButtonTitle: AppStrings
                                          .m3IPGCancelButtonTitle
                                          .tr(),
                                      openSettingsButtonTitle: AppStrings
                                          .m3IPGOpenSettingsButtonTitle
                                          .tr(),
                                      requestPermissionText: (permissionName) =>
                                          AppStrings.m3IPGRequestPermissionText
                                              .tr(
                                                namedArgs: {
                                                  "permissionName":
                                                      permissionName,
                                                },
                                              ),
                                      requestPermissionContentText:
                                          (permissionName) => AppStrings
                                              .m3IPGRequestPermissionContentText
                                              .tr(
                                                namedArgs: {
                                                  "permissionName":
                                                      permissionName,
                                                },
                                              ),
                                      addImageButtonTitle: (content) =>
                                          AppStrings.m3IPGAddImageButtonTitle
                                              .tr(
                                                namedArgs: {'content': content},
                                              ),
                                      onUploadImage: (file) async {
                                        final uploadUrlDataState =
                                            await di<GetUploadUrlUsecase>()
                                                .call();
                                        if (uploadUrlDataState is DataSuccess) {
                                          final fileBytes = await file
                                              .readAsBytes();
                                          await di<UploadMediaUsecase>().call(
                                            params: UploadMediaParams(
                                              presignedUploadUrl:
                                                  uploadUrlDataState
                                                      .data!
                                                      .uploadUrl,
                                              mimeType:
                                                  lookupMimeType(file.path) ??
                                                  'application/octet-stream',
                                              fileBytes: fileBytes,
                                            ),
                                          );
                                          return (
                                            id: uploadUrlDataState
                                                .data!
                                                .mediaId,
                                            path: file.path,
                                          );
                                        }
                                        return null;
                                      },
                                      onImagesChanged: (images) {
                                        context
                                            .read<UpdateLocationFormCubit>()
                                            .mediaIdsChanged(
                                              images
                                                  .map((image) => image.id)
                                                  .toList(),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
