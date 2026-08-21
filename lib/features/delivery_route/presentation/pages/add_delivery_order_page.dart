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
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/shared/widgets/m3_ai_ocr_scan_button.dart';
import 'package:shipgo/shared/widgets/m3_error_text.dart';
import 'package:shipgo/shared/widgets/m3_image_picker.dart';
import 'package:shipgo/shared/widgets/m3_map.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/extracted_order_info_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/add_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/extract_order_info_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_state.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_upload_url_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/upload_media_usecase.dart';

enum LockableField { orderCode, orderName, contactName, contactPhone, address }

class AddDeliveryOrderPage extends StatefulWidget {
  const AddDeliveryOrderPage({super.key});

  @override
  State<AddDeliveryOrderPage> createState() => _AddDeliveryOrderPageState();
}

class _AddDeliveryOrderPageState extends State<AddDeliveryOrderPage> {
  late DeliveryRouteEntity deliveryRoute;
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

    return BlocProvider<AddDeliveryOrderFormCubit>(
      create: (context) =>
          di<AddDeliveryOrderFormCubit>(param1: deliveryRoute.id),
      child: BlocBuilder<AddDeliveryOrderFormCubit, AddDeliveryOrderFormState>(
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
                  'Thêm đơn hàng',
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
              AiOcrScanButton<Map<String, dynamic>>(
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
                onCompleted: (Map<String, dynamic> data) {
                  final addDeliveryOrderFormCubit = context
                      .read<AddDeliveryOrderFormCubit>();
                  final extractedOrderInfo = ExtractedOrderInfoEntity.fromJson(
                    data,
                  );

                  if (!lockedFields.contains(LockableField.orderCode) &&
                      extractedOrderInfo.orderCode.isNotEmpty) {
                    addDeliveryOrderFormCubit.orderCodeInputChanged(
                      extractedOrderInfo.orderCode,
                    );
                    orderCodeInputController.text =
                        extractedOrderInfo.orderCode;
                    orderCodeInputController.selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: orderCodeInputController.text.length,
                          ),
                        ); // Giữ
                  }

                  if (!lockedFields.contains(LockableField.orderName) &&
                      extractedOrderInfo.orderName.isNotEmpty) {
                    addDeliveryOrderFormCubit.orderNameInputChanged(
                      extractedOrderInfo.orderName,
                    );
                    orderNameInputController.text =
                        extractedOrderInfo.orderName;
                    orderNameInputController.selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: orderNameInputController.text.length,
                          ),
                        ); // Giữ
                  }

                  if (!lockedFields.contains(LockableField.contactName) &&
                      extractedOrderInfo.contactName.isNotEmpty) {
                    addDeliveryOrderFormCubit.contactNameInputChanged(
                      extractedOrderInfo.contactName,
                    );
                    contactNameInputController.text =
                        extractedOrderInfo.contactName;
                    contactNameInputController.selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: contactNameInputController.text.length,
                          ),
                        ); // Giữ
                  }

                  if (!lockedFields.contains(LockableField.contactPhone) &&
                      extractedOrderInfo.contactPhone.isNotEmpty) {
                    addDeliveryOrderFormCubit.contactPhoneInputChanged(
                      extractedOrderInfo.contactPhone.replaceAll(
                        RegExp(r'\D'),
                        '',
                      ),
                    );
                    contactPhoneInputController.text = extractedOrderInfo
                        .contactPhone
                        .replaceAll(RegExp(r'\D'), '');
                    contactPhoneInputController.selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: contactPhoneInputController.text.length,
                          ),
                        ); // Giữ
                  }

                  if (!lockedFields.contains(LockableField.address) &&
                      extractedOrderInfo.address.isNotEmpty) {
                    addDeliveryOrderFormCubit.addressInputChanged(
                      extractedOrderInfo.address,
                    );
                    addressInputController.text = extractedOrderInfo.address;
                    addressInputController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: addressInputController.text.length),
                    ); // Giữ
                  }
                },
              ),

              _buildHeaderAction(icon: Icons.save_outlined, label: 'Lưu'),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
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
    final addDeliveryOrderFormCubit = context.read<AddDeliveryOrderFormCubit>();

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
                onChanged: addDeliveryOrderFormCubit.orderCodeInputChanged,
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
              if (addDeliveryOrderFormCubit.state.orderCodeInput.displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(errorText: 'Mã vận đơn không được bỏ trống'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: 'Tên sản phẩm',
            placeholder: 'Nhập tên sản phẩm',
            onChanged: addDeliveryOrderFormCubit.orderNameInputChanged,
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
            onImagesChanged: (images) {
              if (images.isNotEmpty) {
                addDeliveryOrderFormCubit.orderMediaIdChanged(images[0].id);
              }
            },
          ),
        ],
      ),
    );
  }

  // Phần 2: Thông tin người nhận
  Widget _buildRecipientInfoSection(BuildContext context) {
    final addDeliveryOrderFormCubit = context.read<AddDeliveryOrderFormCubit>();

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
                onChanged: addDeliveryOrderFormCubit.contactNameInputChanged,
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
              if (addDeliveryOrderFormCubit
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
                onChanged: addDeliveryOrderFormCubit.contactPhoneInputChanged,
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
              if (addDeliveryOrderFormCubit
                      .state
                      .contactPhoneInput
                      .displayError !=
                  null) ...[
                SizedBox(height: 4),
                if (addDeliveryOrderFormCubit
                        .state
                        .contactPhoneInput
                        .displayError ==
                    ContactPhoneInputValidationError.empty)
                  M3ErrorText(errorText: 'Số điện thoại không được bỏ trống'),
                if (addDeliveryOrderFormCubit
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
                onChanged: addDeliveryOrderFormCubit.addressInputChanged,
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
              if (addDeliveryOrderFormCubit.state.addressInput.displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: 'Địa chỉ người nhận không được bỏ trống',
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          _buildSavedAddressSuggestions(
            selectedIndex: 0,
            suggestions: [],
            onItemSelected: (value) {},
          ),

          const SizedBox(height: 12),

          const Text(
            'Vị trí người nhận *',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildMapPreview(
                address: addDeliveryOrderFormCubit.state.addressInput.value,
                location: addDeliveryOrderFormCubit.state.locationInput.value,
                onLocationSelected: (location) {
                  if (location != null) {
                    addDeliveryOrderFormCubit.locationInputChanged(
                      PointUsecaseParam(
                        x: location.longitude,
                        y: location.latitude,
                      ),
                    );
                  } else {
                    addDeliveryOrderFormCubit.locationInputChanged(null);
                  }
                },
              ),
              if (addDeliveryOrderFormCubit.state.locationInput.displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: 'Vui lòng chọn vị trí người dùng trên bản đồ',
                ),
              ],
            ],
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
    required void Function(List<GridImageItem> images) onImagesChanged,
  }) {
    return M3ImagePickerGrid(
      initialImages: [],
      maxImages: 1,
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
              url: uploadUrlDataState.data!.uploadUrl,
              contentType:
                  lookupMimeType(file.path) ?? 'application/octet-stream',
              file: fileBytes,
            ),
          );
          final pathDataState = await di<GetDownloadUrlUsecase>().call(
            params: GetDownloadUrlParams(
              fileKey: uploadUrlDataState.data!.fileKey,
            ),
          );
          if (pathDataState is DataSuccess) {
            return (
              id: uploadUrlDataState.data!.mediaId,
              path: pathDataState.data!,
            );
          }
        }
        return null;
      },
      onImagesChanged: onImagesChanged,
    );
  }

  Widget _buildImageItem() {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.receipt_long, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Suggestion Card Component
  Widget _buildSavedAddressSuggestions({
    required List<LocationEntity> suggestions,
    required int selectedIndex,
    required ValueChanged<int> onItemSelected,
  }) {
    // Chỉ hiển thị tối đa 10 mục khớp nhất
    final displayList = suggestions.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: lightGreenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Tiêu đề (Đã bỏ nút mũi tên góc phải)
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: primaryGreen, size: 20),
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

          // Danh sách item tối đa 10 mục
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];
              final isSelected = (selectedIndex == index);
              final isBestChoice =
                  (index == 0); // Vị trí đầu tiên là lựa chọn tốt nhất

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        onItemSelected(index), // Truyền callback ra bên ngoài
                    borderRadius: BorderRadius.circular(8),
                    splashColor: primaryGreen.withOpacity(0.12),
                    highlightColor: primaryGreen.withOpacity(0.06),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primaryGreen : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.15),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dòng tên và các Badge (Lựa chọn tốt nhất + Nguồn gốc)
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
                                    // Marker: Lựa chọn tốt nhất nếu xếp hạng đầu tiên
                                    if (isBestChoice) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withAlpha(
                                            (0.1 * 255).round(),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                    // Marker: Lưu bởi bạn hoặc cộng đồng
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            // item.isSavedByUser
                                            false
                                            ? Colors.blue.withAlpha(
                                                (0.1 * 255).round(),
                                              )
                                            : Colors.orange.withAlpha(
                                                (0.1 * 255).round(),
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        // item.isSavedByUser
                                        false ? 'Đã lưu' : 'Cộng đồng',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              // item.isSavedByUser
                                              false
                                              ? Colors.blue[700]
                                              : Colors.orange[800],
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
  }

  // Map Preview Placeholder
  Widget _buildMapPreview({
    required String address,
    Point? location,
    required void Function(LatLng?) onLocationSelected,
  }) {
    return M3MapWidget(
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
