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
import 'package:shipgo/core/widgets/m3_error_text.dart';
import 'package:shipgo/core/widgets/m3_image_picker.dart';
import 'package:shipgo/core/widgets/m3_map.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/upload_media_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/add_location_form/add_location_form_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/add_location_form/add_location_form_state.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/validators/contact_phone.dart';

class AddLocationPage extends StatelessWidget {
  const AddLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    return BlocProvider(
      create: (context) => di<AddLocationFormCubit>(),
      child: Scaffold(
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
                            icon: Icon(Icons.arrow_back_ios_new),
                            color: Colors.white,
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          SizedBox(width: 12),
                          Text(
                            AppStrings.aLPPageTitle.tr(),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),

                      BlocConsumer<AddLocationFormCubit, AddLocationFormState>(
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, state) {
                          final extra =
                              (GoRouterState.of(context).extra)
                                  as Map<String, Object>;
                          if (state is AddLocationFormDone) {
                            (extra['GetMyLocationsCubit']
                                    as GetMyLocationsCubit)
                                .call(
                                  extra['GetMyLocationsParams']
                                      as GetMyLocationsParams,
                                );

                            context.pop();
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is! AddLocationFormInitial,
                        builder: (context, state) {
                          if (state is AddLocationFormLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 4.0,
                                ),
                              ),
                            );
                          }
                          return TextButton(
                            onPressed: () {
                              context.read<AddLocationFormCubit>().submit();
                            },
                            child: Text(
                              AppStrings.aLPSaveButtonTitle.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
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
                            AppStrings.aLPPrimaryInfoLabel.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Column(
                            children: [
                              // Tên địa điểm
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.locationName !=
                                    current.locationName,
                                builder: (context, state) => Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => context
                                          .read<AddLocationFormCubit>()
                                          .locationNameChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .aLPLocationNameFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .aLPLocationNameFieldHintText
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
                                            .aLPLocationNameFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              // Tên người liên hệ
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.contactName != current.contactName,
                                builder: (context, state) => Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => context
                                          .read<AddLocationFormCubit>()
                                          .contactNameChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .aLPContactNameFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .aLPContactNameFieldHintText
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
                                            .aLPContactNameFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              // Số điện thoại liên lạc
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.contactPhone !=
                                    current.contactPhone,
                                builder: (context, state) => Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => context
                                          .read<AddLocationFormCubit>()
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
                                            .aLPContactPhoneFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .aLPContactPhoneFieldHintText
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
                                                  .aLPContactPhoneFieldEmptyError
                                                  .tr()
                                            : AppStrings
                                                  .aLPContactPhoneFieldInvalidError
                                                  .tr(),
                                      ),
                                  ],
                                ),
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
                          SizedBox(height: 12),
                          Column(
                            children: [
                              // Địa chỉ
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.address != current.address,
                                builder: (context, state) => Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => context
                                          .read<AddLocationFormCubit>()
                                          .addressChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        labelText: AppStrings
                                            .aLPAddressFieldLabel
                                            .tr(),
                                        hintText: AppStrings
                                            .aLPAddressFieldHintText
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
                                            .aLPAddressFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.location != current.location ||
                                    previous.address.value !=
                                        current.address.value,
                                builder: (context, state) => Column(
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
                                          : null,
                                      onLocationSelected: (value) {
                                        context
                                            .read<AddLocationFormCubit>()
                                            .locationChanged(value);
                                      },
                                    ),
                                    if (state.location.displayError != null)
                                      M3ErrorText(
                                        padding: EdgeInsets.only(top: 4),
                                        errorText: AppStrings
                                            .aLPLocationFieldError
                                            .tr(),
                                      ),
                                  ],
                                ),
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
                            AppStrings.aLPSecondaryInfoLabel.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ghi chú
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.note != current.note,
                                builder: (context, state) => TextField(
                                  onChanged: (value) => context
                                      .read<AddLocationFormCubit>()
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
                                    labelText: AppStrings.aLPNoteFieldLabel
                                        .tr(),
                                    hintText: AppStrings.aLPNoteFieldHintText
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
                              ),

                              SizedBox(height: 12),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.aLPAttachedImageLabel.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),

                                  BlocBuilder<
                                    AddLocationFormCubit,
                                    AddLocationFormState
                                  >(
                                    buildWhen: (previous, current) =>
                                        previous.mediaIds != current.mediaIds,
                                    builder: (context, state) => M3ImagePickerGrid(
                                      initialImages: [],
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
                                              url: uploadUrlDataState
                                                  .data!
                                                  .uploadUrl,
                                              contentType:
                                                  lookupMimeType(file.path) ??
                                                  'application/octet-stream',
                                              file: fileBytes,
                                            ),
                                          );
                                          final pathDataState =
                                              await di<GetDownloadUrlUsecase>()
                                                  .call(
                                                    params:
                                                        GetDownloadUrlParams(
                                                          fileKey:
                                                              uploadUrlDataState
                                                                  .data!
                                                                  .fileKey,
                                                        ),
                                                  );
                                          if (pathDataState is DataSuccess) {
                                            return (
                                              id: uploadUrlDataState
                                                  .data!
                                                  .mediaId,
                                              path: pathDataState.data!,
                                            );
                                          }
                                        }
                                        return null;
                                      },
                                      onImagesChanged: (images) {
                                        context
                                            .read<AddLocationFormCubit>()
                                            .mediaIdsChanged(images);
                                      },
                                    ),
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
    );
  }
}
