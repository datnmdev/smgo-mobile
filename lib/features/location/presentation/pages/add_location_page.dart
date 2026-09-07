import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/domain/entities/initital_add_location_form_entity.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:smgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:smgo/shared/presentation/widgets/m3_image_picker.dart';
import 'package:smgo/shared/presentation/widgets/m3_map.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:smgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:smgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/add_location_form/add_location_form_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/add_location_form/add_location_form_state.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:smgo/features/location/presentation/inputs/contact_phone.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late final AddLocationFormCubit _addLocationFormCubit;
  late final TextEditingController _locationNameInputController;
  late final TextEditingController _contactNameInputController;
  late final TextEditingController _contactPhoneInputController;
  late final TextEditingController _addressInputController;
  late final TextEditingController _noteInputController;
  late final InititalAddLocationFormEntity? _inititalAddLocationFormData;

  @override
  void initState() {
    super.initState();
    _addLocationFormCubit = di<AddLocationFormCubit>();
    _locationNameInputController = TextEditingController(text: '');
    _contactNameInputController = TextEditingController(text: '');
    _contactPhoneInputController = TextEditingController(text: '');
    _addressInputController = TextEditingController(text: '');
    _noteInputController = TextEditingController(text: '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, Object>;
      _inititalAddLocationFormData = extra['InitialAddLocationFormData'] == null
          ? null
          : extra['InitialAddLocationFormData']
                as InititalAddLocationFormEntity;
      if (_inititalAddLocationFormData != null) {
        // Khởi tạo value cho các input
        _locationNameInputController.text =
            _inititalAddLocationFormData.locationName;
        _contactNameInputController.text =
            _inititalAddLocationFormData.contactName;
        _contactPhoneInputController.text =
            _inititalAddLocationFormData.contactPhone;
        _addressInputController.text = _inititalAddLocationFormData.address;
        _noteInputController.text = _inititalAddLocationFormData.note ?? '';

        // Khởi tạo trạng thái form
        _addLocationFormCubit.initialize(
          locationName: _inititalAddLocationFormData.locationName,
          contactName: _inititalAddLocationFormData.contactName,
          contactPhone: _inititalAddLocationFormData.contactPhone,
          address: _inititalAddLocationFormData.address,
          note: _inititalAddLocationFormData.note,
          location: LatLng(
            _inititalAddLocationFormData.location.y,
            _inititalAddLocationFormData.location.x,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _addLocationFormCubit.close();
    _locationNameInputController.dispose();
    _contactNameInputController.dispose();
    _contactPhoneInputController.dispose();
    _addressInputController.dispose();
    _noteInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    final getMyLocationsCubitInLP = extra['GetMyLocationsCubitInLP'] == null
        ? null
        : extra['GetMyLocationsCubitInLP'] as GetMyLocationsCubit;
    final getMyLocationsParamsInLP = extra['GetMyLocationsParamsInLP'] == null
        ? null
        : extra['GetMyLocationsParamsInLP'] as GetMyLocationsParams;

    return BlocProvider.value(
      value: _addLocationFormCubit,
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
                            icon: Icon(Icons.arrow_back_ios_new, size: 16),
                            color: Colors.white,
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          SizedBox(width: 12),
                          Text(
                            AppStrings.aLPPageTitle.tr(),
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),

                      BlocConsumer<AddLocationFormCubit, AddLocationFormState>(
                        listener: (context, state) {
                          if (state is AddLocationFormDone) {
                            if (getMyLocationsParamsInLP != null &&
                                getMyLocationsCubitInLP != null) {
                              getMyLocationsCubitInLP.call(
                                getMyLocationsParamsInLP,
                              );
                            }

                            // Reset trạng thái form
                            context.read<AddLocationFormCubit>().reset();

                            // Reset form value
                            _locationNameInputController.text = '';
                            _contactNameInputController.text = '';
                            _contactPhoneInputController.text = '';
                            _addressInputController.text = '';
                            _noteInputController.text = '';

                            AppDialogUtils.showSuccess(
                              context: context,
                              title: AppStrings.aLPCreateLocationSuccessTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .aLPCreateLocationSuccessSubtitle
                                  .tr(),
                            );
                          } else if (state is AddLocationFormFailed) {
                            AppDialogUtils.showError(
                              context: context,
                              title: AppStrings.aLPCreateLocationFailedTitle
                                  .tr(),
                              subtitle: AppStrings
                                  .aLPCreateLocationFailedSubtitle
                                  .tr(),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AddLocationFormLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
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
                          SizedBox(height: 16),
                          Column(
                            children: [
                              // Tên địa điểm
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      controller: _locationNameInputController,
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

                              SizedBox(height: 16),

                              // Tên người liên hệ
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      controller: _contactNameInputController,
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

                              SizedBox(height: 16),

                              // Số điện thoại liên lạc
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      controller: _contactPhoneInputController,
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
                            AppStrings.aLPLocationLabel.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            children: [
                              // Địa chỉ
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                builder: (context, state) => Column(
                                  children: [
                                    TextFormField(
                                      controller: _addressInputController,
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

                              SizedBox(height: 16),

                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
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
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ghi chú
                              BlocBuilder<
                                AddLocationFormCubit,
                                AddLocationFormState
                              >(
                                builder: (context, state) => TextFormField(
                                  controller: _noteInputController,
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

                              SizedBox(height: 16),

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
                                  SizedBox(height: 16),

                                  BlocBuilder<
                                    AddLocationFormCubit,
                                    AddLocationFormState
                                  >(
                                    builder: (context, state) => M3ImagePickerGrid(
                                      reset: state.mediaIds.isEmpty,
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
                                            .read<AddLocationFormCubit>()
                                            .mediaIdsChanged(
                                              images.map((e) => e.id).toList(),
                                            );
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
