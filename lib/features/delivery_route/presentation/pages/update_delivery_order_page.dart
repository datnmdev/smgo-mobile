import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/data/models/extracted_order_info_model.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_profile/get_profile_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/update_delivery_order_form/update_delivery_order_form_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/update_delivery_order_form/update_delivery_order_form_state.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/shared/domain/entities/point_entity.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_ai_ocr_scan_button.dart';
import 'package:shipgo/shared/utils/app_dialog_utils.dart';
import 'package:shipgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:shipgo/shared/presentation/widgets/m3_image_picker.dart';
import 'package:shipgo/shared/presentation/widgets/m3_map.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/extracted_order_info_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/extract_order_info_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:shipgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum LockableField { orderCode, orderName, contactName, contactPhone, address }

class UpdateDeliveryOrderPage extends StatefulWidget {
  const UpdateDeliveryOrderPage({super.key});

  @override
  State<UpdateDeliveryOrderPage> createState() =>
      _UpdateDeliveryOrderPageState();
}

class _UpdateDeliveryOrderPageState extends State<UpdateDeliveryOrderPage> {
  late DeliveryRouteEntity deliveryRoute;
  late DeliveryOrderEntity deliveryOrder;
  bool _isGenerating = false;
  final TextEditingController orderCodeInputController =
      TextEditingController();
  final TextEditingController orderNameInputController =
      TextEditingController();
  final TextEditingController contactNameInputController =
      TextEditingController();
  final TextEditingController contactPhoneInputController =
      TextEditingController();
  final TextEditingController addressInputController = TextEditingController();
  final Set<LockableField> lockedFields = {};

  static const Color primaryGreen = Color(0xFF008A45);
  static const Color lightGreenBg = Color(0xFFEFF8F2);
  static const Color cardBg = Colors.white;

  @override
  void dispose() {
    super.dispose();
    orderCodeInputController.dispose();
    orderNameInputController.dispose();
    contactNameInputController.dispose();
    contactPhoneInputController.dispose();
    addressInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    deliveryRoute = extra['DeliveryRouteData'] as DeliveryRouteEntity;
    deliveryOrder = extra['DeliveryOrderData'] as DeliveryOrderEntity;
    final getDeliveryRoutesCubitInDODP =
        extra['GetDeliveryRoutesCubitInDODP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDODP =
        extra['GetDeliveryRoutesUsecaseParamsInDODP']
            as GetDeliveryRoutesUsecaseParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetLocationSuggestionsCubit>(
          create: (context) => di<GetLocationSuggestionsCubit>()
            ..call(
              contactPhone: deliveryOrder.contactPhone,
              address: deliveryOrder.address,
            ),
        ),
        BlocProvider<UpdateDeliveryOrderFormCubit>(
          create: (context) {
            final cubit = di<UpdateDeliveryOrderFormCubit>(
              param1: deliveryOrder.deliveryRouteId,
              param2: deliveryOrder.id,
            );

            // Cập nhật state
            cubit.initialize(
              orderCode: deliveryOrder.orderCode,
              orderName: deliveryOrder.orderName,
              orderMediaId: deliveryOrder.orderMediaId,
              contactName: deliveryOrder.contactName,
              contactPhone: deliveryOrder.contactPhone,
              address: deliveryOrder.address,
              location: deliveryOrder.location,
              appliedLocationId: deliveryOrder.appliedLocationId,
            );

            // Cập nhật form
            orderCodeInputController.text = deliveryOrder.orderCode;
            orderNameInputController.text = deliveryOrder.orderName ?? '';
            contactNameInputController.text = deliveryOrder.contactName;
            contactPhoneInputController.text = deliveryOrder.contactPhone;
            addressInputController.text = deliveryOrder.address;

            return cubit;
          },
        ),
      ],
      child:
          BlocConsumer<
            UpdateDeliveryOrderFormCubit,
            UpdateDeliveryOrderFormState
          >(
            listener: (context, state) async {
              if (state is UpdateDeliveryOrderFormDone) {
                AppDialogUtils.showSuccess(
                  context: context,
                  title: 'Cập nhật thành công!',
                  subtitle: 'Thông tin đơn hàng của bạn đã được lưu.',
                );
                getDeliveryRoutesCubitInDODP.call(
                  params: getDeliveryRoutesUsecaseParamsInDODP,
                );
              } else if (state is UpdateDeliveryOrderFormFailed) {
                AppDialogUtils.showError(
                  context: context,
                  title: 'Cập nhật thất bại!',
                  subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại',
                );
              }
            },
            builder: (context, state) => Scaffold(
              backgroundColor: const Color(0xFFF5F6F8),
              appBar: AppBar(
                backgroundColor: primaryGreen,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    context.pop();
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cập nhật đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      deliveryRoute.name,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                actions: [
                  SmgoAiOcrScanButton<Map<String, dynamic>>(
                    builder: (context, onPressed) {
                      return _buildHeaderAction(
                        icon: Icons.qr_code_scanner,
                        label: 'Quét nhanh',
                        onTap: onPressed,
                      );
                    },
                    llmProcessor: (rawOcrText) async {
                      return await _runInference(rawOcrText);
                    },
                    promptBuilder: (ocrText) => ocrText,
                    parser: (llmOutput) {
                      var cleanJson = llmOutput.trim();
                      cleanJson = cleanJson
                          .replaceFirst(
                            RegExp(r'^```json\s*', caseSensitive: false),
                            '',
                          )
                          .replaceFirst(RegExp(r'^```\s*'), '')
                          .replaceFirst(RegExp(r'\s*```$'), '')
                          .trim();
                      final startIndex = cleanJson.indexOf('{');
                      final endIndex = cleanJson.lastIndexOf('}');
                      cleanJson = cleanJson.substring(startIndex, endIndex + 1);
                      return jsonDecode(cleanJson);
                    },
                    onCompleted: (json) {
                      final updateDeliveryOrderFormCubit = context
                          .read<UpdateDeliveryOrderFormCubit>();
                      final getLocationSuggestionsCubit = context
                          .read<GetLocationSuggestionsCubit>();
                      final extractedOrderInfoModel =
                          ExtractedOrderInfoModel.fromJson(json);
                      final extractedOrderInfo = ExtractedOrderInfoEntity(
                        orderCode: extractedOrderInfoModel.orderCode,
                        orderName: extractedOrderInfoModel.orderName,
                        contactName: extractedOrderInfoModel.contactName,
                        contactPhone: extractedOrderInfoModel.contactPhone,
                        address: extractedOrderInfoModel.address,
                      );

                      if (!lockedFields.contains(LockableField.orderCode) &&
                          extractedOrderInfo.orderCode.isNotEmpty) {
                        updateDeliveryOrderFormCubit.orderCodeInputChanged(
                          extractedOrderInfo.orderCode,
                        );
                        orderCodeInputController.text =
                            extractedOrderInfo.orderCode;
                      }

                      if (!lockedFields.contains(LockableField.orderName) &&
                          extractedOrderInfo.orderName.isNotEmpty) {
                        updateDeliveryOrderFormCubit.orderNameInputChanged(
                          extractedOrderInfo.orderName,
                        );
                        orderNameInputController.text =
                            extractedOrderInfo.orderName;
                      }

                      if (!lockedFields.contains(LockableField.contactName) &&
                          extractedOrderInfo.contactName.isNotEmpty) {
                        updateDeliveryOrderFormCubit.contactNameInputChanged(
                          extractedOrderInfo.contactName,
                        );
                        contactNameInputController.text =
                            extractedOrderInfo.contactName;
                      }

                      if (!lockedFields.contains(LockableField.contactPhone) &&
                          extractedOrderInfo.contactPhone.isNotEmpty) {
                        updateDeliveryOrderFormCubit.contactPhoneInputChanged(
                          extractedOrderInfo.contactPhone.replaceAll(
                            RegExp(r'\D'),
                            '',
                          ),
                        );
                        getLocationSuggestionsCubit.call(
                          contactPhone: extractedOrderInfo.contactPhone
                              .replaceAll(RegExp(r'\D'), ''),
                          address: updateDeliveryOrderFormCubit
                              .state
                              .addressInput
                              .value,
                        );
                        contactPhoneInputController.text = extractedOrderInfo
                            .contactPhone
                            .replaceAll(RegExp(r'\D'), '');
                      }

                      if (!lockedFields.contains(LockableField.address) &&
                          extractedOrderInfo.address.isNotEmpty) {
                        getLocationSuggestionsCubit.call(
                          contactPhone: updateDeliveryOrderFormCubit
                              .state
                              .contactPhoneInput
                              .value,
                          address: extractedOrderInfo.address,
                        );
                        updateDeliveryOrderFormCubit.addressInputChanged(
                          extractedOrderInfo.address,
                        );
                        addressInputController.text =
                            extractedOrderInfo.address;
                      }
                    },
                  ),

                  _buildHeaderAction(
                    icon: Icons.save_outlined,
                    label: 'Lưu',
                    isLoading: state is UpdateDeliveryOrderFormLoading,
                    onTap: () {
                      context.read<UpdateDeliveryOrderFormCubit>().submit(
                        oldOrderCode: deliveryOrder.orderCode,
                        existingDeliveryOrders: deliveryRoute.orders,
                      );
                    },
                  ),

                  const SizedBox(width: 8),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildOrderInfoSection(context),
                    const SizedBox(height: 12),
                    _buildRecipientInfoSection(context),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<String> _runInference(String ocrText) async {
    if (_isGenerating) {
      throw Exception('AI đang xử lý yêu cầu trước đó');
    }
    try {
      _isGenerating = true;
      final cleanOcrText = ocrText
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      if (cleanOcrText.isEmpty) {
        throw Exception('OCR không nhận diện được nội dung');
      }

      final dataState = await di<ExtractOrderInfoUsecase>().call(
        params: ExtractOrderInfoUsecaseParams(ocrText: cleanOcrText),
      );

      if (dataState is DataSuccess) {
        return dataState.data!;
      } else {
        throw dataState.error!;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isGenerating = false;
    }
  }

  // Header Actions
  static Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    void Function()? onTap,
    bool isLoading = false, // Thêm tham số trạng thái loading
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap, // Vô hiệu hóa tap khi đang loading
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thay thế icon bằng CircularProgressIndicator khi loading
            isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // Phần 1: Thông tin đơn hàng
  Widget _buildOrderInfoSection(BuildContext context) {
    final updateDeliveryOrderFormCubit = context
        .read<UpdateDeliveryOrderFormCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.qr_code, 'Thông tin đơn hàng'),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildInputField(
                label: 'Mã vận đơn *',
                placeholder: 'Nhập mã vận đơn',
                onChanged: updateDeliveryOrderFormCubit.orderCodeInputChanged,
                controller: orderCodeInputController,
                isLocked: lockedFields.contains(LockableField.orderCode),
                onLockToggle: () {
                  setState(() {
                    if (lockedFields.contains(LockableField.orderCode)) {
                      lockedFields.remove(LockableField.orderCode);
                    } else {
                      lockedFields.add(LockableField.orderCode);
                    }
                  });
                },
              ),
              if (updateDeliveryOrderFormCubit
                      .state
                      .orderCodeInput
                      .displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(errorText: 'Mã vận đơn không được bỏ trống'),
              ],
              if (updateDeliveryOrderFormCubit.isOrderCodeDuplicated(
                oldOrderCode: deliveryOrder.orderCode,
                existingDeliveryOrders: deliveryRoute.orders,
              )) ...[
                SizedBox(height: 4),
                M3ErrorText(errorText: 'Mã vận đơn đã tồn tại'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: 'Tên sản phẩm',
            placeholder: 'Nhập tên sản phẩm',
            onChanged: updateDeliveryOrderFormCubit.orderNameInputChanged,
            controller: orderNameInputController,
            isLocked: lockedFields.contains(LockableField.orderName),
            onLockToggle: () {
              setState(() {
                if (lockedFields.contains(LockableField.orderName)) {
                  lockedFields.remove(LockableField.orderName);
                } else {
                  lockedFields.add(LockableField.orderName);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Ảnh chụp của đơn hàng',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildImagePickerList(
            initialImages: [
              if (deliveryOrder.orderMediaId != null &&
                  deliveryOrder.orderMediaUrl != null)
                GridImageItem(
                  id: deliveryOrder.orderMediaId!,
                  path: deliveryOrder.orderMediaUrl!,
                ),
            ],
            maxImages: 1,
            onImagesChanged: (images) {
              updateDeliveryOrderFormCubit.orderMediaIdChanged(
                images.isNotEmpty ? images[0].id : null,
              );
              updateDeliveryOrderFormCubit.orderMediaUrlChanged(
                images.isNotEmpty ? images[0].path : null,
              );
            },
          ),
        ],
      ),
    );
  }

  // Phần 2: Thông tin người nhận
  Widget _buildRecipientInfoSection(BuildContext context) {
    final updateDeliveryOrderFormCubit = context
        .read<UpdateDeliveryOrderFormCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.person_outline, 'Thông tin người nhận'),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildInputField(
                label: 'Tên người nhận *',
                placeholder: 'Nhập tên người nhận',
                onChanged: updateDeliveryOrderFormCubit.contactNameInputChanged,
                controller: contactNameInputController,
                isLocked: lockedFields.contains(LockableField.contactName),
                onLockToggle: () {
                  setState(() {
                    if (lockedFields.contains(LockableField.contactName)) {
                      lockedFields.remove(LockableField.contactName);
                    } else {
                      lockedFields.add(LockableField.contactName);
                    }
                  });
                },
              ),
              if (updateDeliveryOrderFormCubit
                      .state
                      .contactNameInput
                      .displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(errorText: 'Tên người nhận không được bỏ trống'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildInputField(
                label: 'Số điện thoại *',
                placeholder: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  updateDeliveryOrderFormCubit.contactPhoneInputChanged(value);
                  context.read<GetLocationSuggestionsCubit>().call(
                    contactPhone: value,
                    address:
                        updateDeliveryOrderFormCubit.state.addressInput.value,
                  );
                },
                controller: contactPhoneInputController,
                isLocked: lockedFields.contains(LockableField.contactPhone),
                onLockToggle: () {
                  setState(() {
                    if (lockedFields.contains(LockableField.contactPhone)) {
                      lockedFields.remove(LockableField.contactPhone);
                    } else {
                      lockedFields.add(LockableField.contactPhone);
                    }
                  });
                },
              ),
              if (updateDeliveryOrderFormCubit
                      .state
                      .contactPhoneInput
                      .displayError !=
                  null) ...[
                SizedBox(height: 4),
                if (updateDeliveryOrderFormCubit
                        .state
                        .contactPhoneInput
                        .displayError ==
                    ContactPhoneInputValidationError.empty)
                  M3ErrorText(errorText: 'Số điện thoại không được bỏ trống'),
                if (updateDeliveryOrderFormCubit
                        .state
                        .contactPhoneInput
                        .displayError ==
                    ContactPhoneInputValidationError.invalid)
                  M3ErrorText(errorText: 'Số điện thoại không hợp lệ'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildInputField(
                label: 'Địa chỉ người nhận *',
                placeholder: 'Nhập địa chỉ',
                onChanged: (value) {
                  updateDeliveryOrderFormCubit.addressInputChanged(value);
                  context.read<GetLocationSuggestionsCubit>().call(
                    contactPhone: updateDeliveryOrderFormCubit
                        .state
                        .contactPhoneInput
                        .value,
                    address: value,
                  );
                },
                controller: addressInputController,
                isLocked: lockedFields.contains(LockableField.address),
                onLockToggle: () {
                  setState(() {
                    if (lockedFields.contains(LockableField.address)) {
                      lockedFields.remove(LockableField.address);
                    } else {
                      lockedFields.add(LockableField.address);
                    }
                  });
                },
              ),
              if (updateDeliveryOrderFormCubit
                      .state
                      .addressInput
                      .displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: 'Địa chỉ người nhận không được bỏ trống',
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          BlocBuilder<GetLocationSuggestionsCubit, GetLocationSuggestionsState>(
            builder: (context, state) {
              final updateDeliveryOrderFormCubit = context
                  .read<UpdateDeliveryOrderFormCubit>();
              final suggestions = state is GetLocationSuggestionsDone
                  ? state.locationSuggestions.data
                  : <LocationEntity>[];
              return _buildSavedAddressSuggestions(
                selectedIndex: suggestions.indexWhere(
                  (suggestion) =>
                      suggestion.id ==
                      updateDeliveryOrderFormCubit.state.appliedLocationId,
                ),
                isLoading: state is GetLocationSuggestionsLoading,
                suggestions: suggestions,
                onItemSelected: (value) {
                  if (updateDeliveryOrderFormCubit.state.appliedLocationId ==
                      value) {
                    updateDeliveryOrderFormCubit.appliedLocationIdChanged(null);
                    updateDeliveryOrderFormCubit.locationInputChanged(null);
                    return;
                  }
                  updateDeliveryOrderFormCubit.appliedLocationIdChanged(value);
                  final location = suggestions
                      .where((sug) => sug.id == value)
                      .first
                      .location;
                  updateDeliveryOrderFormCubit.locationInputChanged(
                    PointEntity(x: location.x, y: location.y),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 12),

          const Text(
            'Vị trí người nhận *',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          BlocBuilder<GetLocationSuggestionsCubit, GetLocationSuggestionsState>(
            builder: (context, state) => Column(
              children: [
                _buildMapPreview(
                  mapMode:
                      updateDeliveryOrderFormCubit.state.appliedLocationId !=
                          null
                      ? MapMode.view
                      : MapMode.select,
                  address:
                      updateDeliveryOrderFormCubit.state.addressInput.value,
                  location:
                      updateDeliveryOrderFormCubit.state.locationInput.value,
                  onLocationSelected: (location) {
                    if (location != null) {
                      updateDeliveryOrderFormCubit.locationInputChanged(
                        PointEntity(
                          x: location.longitude,
                          y: location.latitude,
                        ),
                      );
                    } else {
                      updateDeliveryOrderFormCubit.locationInputChanged(null);
                    }
                  },
                ),
                if (updateDeliveryOrderFormCubit
                        .state
                        .locationInput
                        .displayError !=
                    null) ...[
                  SizedBox(height: 4),
                  M3ErrorText(
                    errorText: 'Vui lòng chọn vị trí người dùng trên bản đồ',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section Header Component
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
      ],
    );
  }

  // Custom Input Field Component
  Widget _buildInputField({
    required String label,
    required String placeholder,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isLocked = false,
    void Function(String value)? onChanged,
    void Function()? onLockToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          readOnly: isLocked,
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            suffixIcon: OutlinedButton.icon(
              onPressed: onLockToggle,
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
                shape: CircleBorder(),
                iconColor: Colors.grey,
              ),
              label: Icon(
                isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  // Horizontal Image List Component
  Widget _buildImagePickerList({
    List<GridImageItem>? initialImages,
    int maxImages = 1,
    required void Function(List<GridImageItem> images) onImagesChanged,
  }) {
    return M3ImagePickerGrid(
      initialImages: initialImages ?? [],
      maxImages: maxImages, // Sử dụng biến maxImages
      takeNewPhotoTitle: AppStrings.m3IPGTakeNewPhotoTitle.tr(),
      selectFromLibrary: AppStrings.m3IPGSelectFromLibrary.tr(),
      cameraTitle: AppStrings.m3IPGCameraTitle.tr(),
      imageLibraryTitle: AppStrings.m3IPGImageLibraryTitle.tr(),
      cancelButtonTitle: AppStrings.m3IPGCancelButtonTitle.tr(),
      openSettingsButtonTitle: AppStrings.m3IPGOpenSettingsButtonTitle.tr(),
      requestPermissionText: (permissionName) => AppStrings
          .m3IPGRequestPermissionText
          .tr(namedArgs: {"permissionName": permissionName}),
      requestPermissionContentText: (permissionName) => AppStrings
          .m3IPGRequestPermissionContentText
          .tr(namedArgs: {"permissionName": permissionName}),
      addImageButtonTitle: (content) => AppStrings.m3IPGAddImageButtonTitle.tr(
        namedArgs: {'content': content},
      ),
      onUploadImage: (file) async {
        final uploadUrlDataState = await di<GetUploadUrlUsecase>().call();
        if (uploadUrlDataState is DataSuccess) {
          final fileBytes = await file.readAsBytes();
          await di<UploadMediaUsecase>().call(
            params: UploadMediaParams(
              presignedUploadUrl: uploadUrlDataState.data!.uploadUrl,
              mimeType: lookupMimeType(file.path) ?? 'application/octet-stream',
              fileBytes: fileBytes,
            ),
          );
          return (id: uploadUrlDataState.data!.mediaId, path: file.path);
        }
        return null;
      },
      onImagesChanged: onImagesChanged,
    );
  }

  // Suggestion Card Component
  Widget _buildSavedAddressSuggestions({
    required List<LocationEntity> suggestions,
    required int selectedIndex,
    required ValueChanged<String> onItemSelected,
    bool isLoading = false,
  }) {
    return BlocProvider<GetProfileCubit>(
      create: (context) => di<GetProfileCubit>()..call(),
      child: BlocBuilder<GetProfileCubit, GetProfileState>(
        builder: (context, state) {
          final isGetProfileDone = state is GetProfileDone;
          final profileId = isGetProfileDone ? state.profile.id : null;

          return Container(
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần Tiêu đề
                Row(
                  children: const [
                    Icon(
                      Icons.lightbulb_outline,
                      color: primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gợi ý vị trí chính xác',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Vị trí này được lưu lại bởi bạn hoặc được chia sẻ bởi cộng đồng',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Xử lý hiển thị tùy theo trạng thái isLoading
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(
                        color: primaryGreen,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (suggestions.isEmpty)
                  // (Tùy chọn) Hiển thị thông báo khi không có dữ liệu
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Không tìm thấy gợi ý nào',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  // Danh sách item tối đa 10 mục (Giữ nguyên logic cũ)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final item = suggestions[index];
                      final isSelected = (selectedIndex == index);
                      final isBestChoice = (index == 0);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onItemSelected(suggestions[index].id),
                            borderRadius: BorderRadius.circular(8),
                            splashColor: primaryGreen.withAlpha(
                              (0.12 * 255).round(),
                            ),
                            highlightColor: primaryGreen.withAlpha(
                              (0.06 * 255).round(),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryGreen
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: primaryGreen.withAlpha(
                                        (0.15 * 255).round(),
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.contactName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            if (isBestChoice) ...[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: primaryGreen.withAlpha(
                                                    (0.1 * 255).round(),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Tốt nhất',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryGreen,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Skeletonizer(
                                              enabled: !isGetProfileDone,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withAlpha(
                                                        (0.1 * 255).round(),
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  suggestions[index].userId ==
                                                          profileId
                                                      ? 'Bởi tôi'
                                                      : 'Cộng đồng',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.contactPhone,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.address,
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
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Map Preview Placeholder
  Widget _buildMapPreview({
    MapMode mapMode = MapMode.select,
    required String address,
    Point? location,
    required void Function(LatLng?) onLocationSelected,
  }) {
    return M3MapWidget(
      mode: mapMode,
      userAgentPackageName: Env.packageName,
      selectLocationError: AppStrings.m3MSelectLocationError.tr(),
      cannotGetLocationError: AppStrings.m3MCannotGetLocationError.tr(),
      mapTemplateUrl: Env.mapTemplateUrl,
      address: address,
      center: location != null ? LatLng(location.y, location.x) : null,
      onLocationSelected: onLocationSelected,
    );
  }
}
