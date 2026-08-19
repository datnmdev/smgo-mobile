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
import 'package:shipgo/features/location/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/upload_media_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/get_urls/get_urls_cubic.dart';
import 'package:shipgo/features/location/presentation/bloc/get_urls/get_urls_state.dart';
import 'package:shipgo/features/location/presentation/bloc/update_location_form/update_location_form_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/update_location_form/update_location_form_state.dart';
import 'package:shipgo/features/location/presentation/validators/contact_phone.dart';

class UpdateLocationPage extends StatefulWidget {
  const UpdateLocationPage({super.key});

  @override
  State<UpdateLocationPage> createState() => _UpdateLocationPageState();
}

class _UpdateLocationPageState extends State<UpdateLocationPage> {
  late UpdateLocationFormCubit _updateLocationFormCubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final extra = GoRouterState.of(context).extra as Map<String, Object>;
      final locationData = extra['LocationData'] as LocationEntity;
      _updateLocationFormCubit = di<UpdateLocationFormCubit>(
        param1: locationData.id,
      );
      _updateLocationFormCubit.locationNameChanged(locationData.locationName);
      _updateLocationFormCubit.contactNameChanged(locationData.contactName);
      _updateLocationFormCubit.contactPhoneChanged(locationData.contactPhone);
      _updateLocationFormCubit.addressChanged(locationData.address);
      _updateLocationFormCubit.locationChanged(
        LatLng(locationData.location.y, locationData.location.x),
      );
      _updateLocationFormCubit.noteChanged(locationData.note ?? '');
      _updateLocationFormCubit.mediaIdsChanged(
        locationData.media.map((e) => e.id).toList(),
      );
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final locationData = extra['LocationData'] as LocationEntity;
    final getMyLocationsCubitInLP =
        extra['GetMyLocationsCubitInLP'] as GetMyLocationsCubit;
    final getMyLocationsParamsInLP =
        extra['GetMyLocationsParamsInLP'] as GetMyLocationsParams;
    final getMyLocationsCubitInLDP =
        extra['GetMyLocationsCubitInLDP'] as GetMyLocationsCubit;
    final getMyLocationsParamsInLDP =
        extra['GetMyLocationsParamsInLDP'] as GetMyLocationsParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<UpdateLocationFormCubit>(
          create: (context) => _updateLocationFormCubit,
        ),
        BlocProvider<GetUrlsCubit>(
          create: (context) =>
              di<GetUrlsCubit>()
                ..call(locationData.media.map((e) => e.fileKey).toList()),
        ),
      ],
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
                            AppStrings.uLPPageTitle.tr(),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),

                      BlocConsumer<
                        UpdateLocationFormCubit,
                        UpdateLocationFormState
                      >(
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, state) {
                          if (state is UpdateLocationFormDone) {
                            getMyLocationsCubitInLDP.call(
                              getMyLocationsParamsInLDP,
                            );
                            getMyLocationsCubitInLP.call(
                              getMyLocationsParamsInLP,
                            );
                            context.pop();
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is! UpdateLocationFormInitial,
                        builder: (context, state) {
                          if (state is UpdateLocationFormLoading) {
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
                              context.read<UpdateLocationFormCubit>().submit();
                            },
                            child: Text(
                              AppStrings.uLPSaveButtonTitle.tr(),
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
                            AppStrings.uLPPrimaryInfoLabel.tr(),
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
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.locationName !=
                                    current.locationName,
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      initialValue: locationData.locationName,
                                      onChanged: (value) => context
                                          .read<UpdateLocationFormCubit>()
                                          .locationNameChanged(value),
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
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
                              ),

                              SizedBox(height: 12),

                              // Tên người liên hệ
                              BlocBuilder<
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.contactName != current.contactName,
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      initialValue: locationData.contactName,
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
                              ),

                              SizedBox(height: 12),

                              // Số điện thoại liên lạc
                              BlocBuilder<
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.contactPhone !=
                                    current.contactPhone,
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      initialValue: locationData.contactPhone,
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
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.address != current.address,
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      initialValue: locationData.address,
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
                              ),

                              SizedBox(height: 12),

                              BlocBuilder<
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
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
                          SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ghi chú
                              BlocBuilder<
                                UpdateLocationFormCubit,
                                UpdateLocationFormState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.note != current.note,
                                builder: (context, state) => TextFormField(
                                  initialValue: locationData.note,
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
                                  SizedBox(height: 8),

                                  BlocBuilder<
                                    UpdateLocationFormCubit,
                                    UpdateLocationFormState
                                  >(
                                    builder: (context, state) =>
                                        BlocBuilder<GetUrlsCubit, GetUrlsState>(
                                          builder: (context, state) => M3ImagePickerGrid(
                                            key: ValueKey(
                                              state is GetUrlsDone
                                                  ? state.urls.hashCode
                                                  : state.hashCode,
                                            ),
                                            initialImages: [
                                              if (state is GetUrlsDone)
                                                for (
                                                  int i = 0;
                                                  i < locationData.media.length;
                                                  ++i
                                                )
                                                  GridImageItem(
                                                    id: locationData
                                                        .media[i]
                                                        .id,
                                                    path: state.urls[i],
                                                  ),
                                            ],
                                            takeNewPhotoTitle: AppStrings
                                                .m3IPGTakeNewPhotoTitle
                                                .tr(),
                                            selectFromLibrary: AppStrings
                                                .m3IPGSelectFromLibrary
                                                .tr(),
                                            cameraTitle: AppStrings
                                                .m3IPGCameraTitle
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
                                            requestPermissionText:
                                                (permissionName) => AppStrings
                                                    .m3IPGRequestPermissionText
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
                                                AppStrings
                                                    .m3IPGAddImageButtonTitle
                                                    .tr(
                                                      namedArgs: {
                                                        'content': content,
                                                      },
                                                    ),
                                            onUploadImage: (file) async {
                                              final uploadUrlDataState =
                                                  await di<
                                                        GetUploadUrlUsecase
                                                      >()
                                                      .call();
                                              if (uploadUrlDataState
                                                  is DataSuccess) {
                                                final fileBytes = await file
                                                    .readAsBytes();
                                                await di<UploadMediaUsecase>().call(
                                                  params: UploadMediaParams(
                                                    url: uploadUrlDataState
                                                        .data!
                                                        .uploadUrl,
                                                    contentType:
                                                        lookupMimeType(
                                                          file.path,
                                                        ) ??
                                                        'application/octet-stream',
                                                    file: fileBytes,
                                                  ),
                                                );
                                                final pathDataState =
                                                    await di<
                                                          GetDownloadUrlUsecase
                                                        >()
                                                        .call(
                                                          params: GetDownloadUrlParams(
                                                            fileKey:
                                                                uploadUrlDataState
                                                                    .data!
                                                                    .fileKey,
                                                          ),
                                                        );
                                                if (pathDataState
                                                    is DataSuccess) {
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
                                                  .read<
                                                    UpdateLocationFormCubit
                                                  >()
                                                  .mediaIdsChanged(
                                                    images
                                                        .map(
                                                          (image) => image.id,
                                                        )
                                                        .toList(),
                                                  );
                                            },
                                          ),
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
