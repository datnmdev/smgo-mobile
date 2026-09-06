import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/data/models/extracted_order_info_model.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_state.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_state.dart';
import 'package:smgo/features/delivery_route/presentation/widgets/imported_orders.dart';
import 'package:smgo/features/delivery_route/presentation/widgets/json_import_bottom_sheet.dart';
import 'package:smgo/shared/domain/entities/location_entity.dart';
import 'package:smgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:smgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:smgo/shared/presentation/widgets/smgo_ai_ocr_scan_button.dart';
import 'package:smgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:smgo/shared/presentation/widgets/m3_image_picker.dart';
import 'package:smgo/shared/presentation/widgets/m3_map.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/extracted_order_info_entity.dart';
import 'package:smgo/features/delivery_route/domain/usecases/add_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/domain/usecases/extract_order_info_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_cubit.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_state.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum LockableField { orderCode, orderName, contactName, contactPhone, address }

class AddDeliveryOrderPage extends StatefulWidget {
  const AddDeliveryOrderPage({super.key});

  @override
  State<AddDeliveryOrderPage> createState() => _AddDeliveryOrderPageState();
}

class _AddDeliveryOrderPageState extends State<AddDeliveryOrderPage> {
  DeliveryRouteEntity? _deliveryRoute;
  bool _isGenerating = false;
  final TextEditingController _orderCodeInputController =
      TextEditingController();
  final TextEditingController _orderNameInputController =
      TextEditingController();
  final TextEditingController _contactNameInputController =
      TextEditingController();
  final TextEditingController _contactPhoneInputController =
      TextEditingController();
  final TextEditingController _addressInputController = TextEditingController();
  final Set<LockableField> _lockedFields = {};
  List<ExtractedOrderInfoEntity> _importedOrderInfos = [];

  static const Color primaryGreen = Color(0xFF008A45);
  static const Color lightGreenBg = Color(0xFFEFF8F2);
  static const Color cardBg = Colors.white;

  @override
  void dispose() {
    _orderCodeInputController.dispose();
    _orderNameInputController.dispose();
    _contactNameInputController.dispose();
    _contactPhoneInputController.dispose();
    _addressInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    _deliveryRoute =
        _deliveryRoute ?? extra['DeliveryRouteData'] as DeliveryRouteEntity;
    final getDeliveryRoutesCubitInDOP =
        extra['GetDeliveryRoutesCubitInDOP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDOP =
        extra['GetDeliveryRoutesUsecaseParamsInDOP']
            as GetDeliveryRoutesUsecaseParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AddDeliveryOrderFormCubit>(
          create: (context) =>
              di<AddDeliveryOrderFormCubit>(param1: _deliveryRoute!.id),
        ),
        BlocProvider<GetLocationSuggestionsCubit>(
          create: (context) => di<GetLocationSuggestionsCubit>(),
        ),
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (context) => di<GetDeliveryRoutesCubit>()
            ..call(
              params: GetDeliveryRoutesUsecaseParams(
                pageNumber: 1,
                pageSize: 1,
                id: _deliveryRoute!.id,
              ),
            ),
        ),
      ],
      child: BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
        listener: (context, state) {
          if (state is GetDeliveryRoutesDone) {
            setState(() {
              _deliveryRoute = state.routes.firstOrNull ?? _deliveryRoute;
            });
          }
        },
        builder: (_, _) =>
            BlocConsumer<AddDeliveryOrderFormCubit, AddDeliveryOrderFormState>(
              listener: (context, state) async {
                final addDeliveryOrderFormCubit = context
                    .read<AddDeliveryOrderFormCubit>();

                if (state is AddDeliveryOrderFormDone) {
                  getDeliveryRoutesCubitInDOP.call(
                    params: getDeliveryRoutesUsecaseParamsInDOP,
                  );
                  context.read<GetDeliveryRoutesCubit>().call(
                    params: GetDeliveryRoutesUsecaseParams(
                      pageNumber: 1,
                      pageSize: 1,
                      id: _deliveryRoute!.id,
                    ),
                  );

                  // Hiển thị thông báo tạo đơn hàng thành công
                  AppDialogUtils.showSuccess(
                    context: context,
                    title: AppStrings.aDOPCreateOrderSuccessDialogTitle.tr(),
                    subtitle: AppStrings.aDOPCreateOrderSuccessDialogSubtitle
                        .tr(),
                    content: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            AppStrings.aDOPOrderCodeInfoLabel.tr(),
                            addDeliveryOrderFormCubit
                                .state
                                .orderCodeInput
                                .value,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            AppStrings.aDOPProductNameInfoLabel.tr(),
                            addDeliveryOrderFormCubit.state.orderName ??
                                AppStrings.aDOPNoOrderName.tr(),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            AppStrings.aDOPRecipientNameInfoLabel.tr(),
                            addDeliveryOrderFormCubit
                                .state
                                .contactNameInput
                                .value,
                          ),
                        ],
                      ),
                    ),
                  );

                  // Reset lại trạng thái cubit
                  addDeliveryOrderFormCubit.reset();

                  // Reset lại giá trị form
                  _orderCodeInputController.text = '';
                  _orderNameInputController.text = '';
                  _contactNameInputController.text = '';
                  _contactPhoneInputController.text = '';
                  _addressInputController.text = '';
                  context.read<GetLocationSuggestionsCubit>().call(
                    contactPhone: '',
                    address: '',
                  );
                } else if (state is AddDeliveryOrderFormFailed) {
                  if (state.error is DioException &&
                      (state.error as DioException)
                              .response
                              ?.data?['error']?['code'] ==
                          'ORDER_LIMIT_EXCEEDED') {
                    AppDialogUtils.showCustomDialog(
                      context: context,
                      title: AppStrings.aDOPUpgradePlanDialogTitle.tr(),
                      subtitle: AppStrings.aDOPUpgradePlanDialogSubtitle.tr(),
                      iconData: Icons.rocket_launch_outlined,
                      actions: [
                        SmgoButton(
                          onPressed: () {
                            context.pop();
                            context.pushNamed(AppRouteNames.subscription);
                          },
                          text: AppStrings.aDOPUpgradeNowButtonLabel.tr(),
                          textColor: Colors.white,
                          primaryColor: AppColors.primary,
                        ),
                      ],
                    );
                    return;
                  }
                  AppDialogUtils.showSuccess(
                    context: context,
                    title: AppStrings.aDOPCreateOrderFailedDialogTitle.tr(),
                    subtitle: AppStrings.aDOPCreateOrderFailedDialogSubtitle
                        .tr(),
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
                        AppStrings.aDOPPageTitle.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _deliveryRoute!.name,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  actions: [
                    _buildHeaderAction(
                      icon: Icons.document_scanner,
                      label: AppStrings.aDOPQuickAddButtonLabel.tr(),
                      onTap: () {
                        _showOptionsBottomSheet(context: context);
                      },
                    ),

                    _buildHeaderAction(
                      icon: Icons.save_outlined,
                      label: AppStrings.aDOPSaveButtonLabel.tr(),
                      isLoading: state is AddDeliveryOrderFormLoading,
                      onTap: () {
                        context.read<AddDeliveryOrderFormCubit>().submit(
                          existingDeliveryOrders: _deliveryRoute!.orders,
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
                      if (_importedOrderInfos.isNotEmpty)
                        _buildImportedOrdersSection(context: context),
                      const SizedBox(height: 12),
                      _buildOrderInfoSection(context),
                      const SizedBox(height: 12),
                      _buildRecipientInfoSection(context),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _applyExtractedOrderInfoIntoForm({
    required BuildContext context,
    required ExtractedOrderInfoEntity extractedOrderInfo,
  }) {
    final addDeliveryOrderFormCubit = context.read<AddDeliveryOrderFormCubit>();
    final getLocationSuggestionsCubit = context
        .read<GetLocationSuggestionsCubit>();

    if (!_lockedFields.contains(LockableField.orderCode) &&
        extractedOrderInfo.orderCode.isNotEmpty) {
      addDeliveryOrderFormCubit.orderCodeInputChanged(
        extractedOrderInfo.orderCode,
      );
      _orderCodeInputController.text = extractedOrderInfo.orderCode;
    }

    if (!_lockedFields.contains(LockableField.orderName) &&
        extractedOrderInfo.orderName.isNotEmpty) {
      addDeliveryOrderFormCubit.orderNameInputChanged(
        extractedOrderInfo.orderName,
      );
      _orderNameInputController.text = extractedOrderInfo.orderName;
    }

    if (!_lockedFields.contains(LockableField.contactName) &&
        extractedOrderInfo.contactName.isNotEmpty) {
      addDeliveryOrderFormCubit.contactNameInputChanged(
        extractedOrderInfo.contactName,
      );
      _contactNameInputController.text = extractedOrderInfo.contactName;
    }

    if (!_lockedFields.contains(LockableField.contactPhone) &&
        extractedOrderInfo.contactPhone.isNotEmpty) {
      addDeliveryOrderFormCubit.contactPhoneInputChanged(
        extractedOrderInfo.contactPhone.replaceAll(RegExp(r'\D'), ''),
      );
      getLocationSuggestionsCubit.call(
        contactPhone: extractedOrderInfo.contactPhone.replaceAll(
          RegExp(r'\D'),
          '',
        ),
        address: addDeliveryOrderFormCubit.state.addressInput.value,
      );
      _contactPhoneInputController.text = extractedOrderInfo.contactPhone
          .replaceAll(RegExp(r'\D'), '');
    }

    if (!_lockedFields.contains(LockableField.address) &&
        extractedOrderInfo.address.isNotEmpty) {
      getLocationSuggestionsCubit.call(
        contactPhone: addDeliveryOrderFormCubit.state.contactPhoneInput.value,
        address: extractedOrderInfo.address,
      );
      addDeliveryOrderFormCubit.addressInputChanged(extractedOrderInfo.address);
      _addressInputController.text = extractedOrderInfo.address;
    }
  }

  void _showOptionsBottomSheet({required BuildContext context}) {
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh gạch ngang nhỏ trên đỉnh BottomSheet (Drag Handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Các Option
              SmgoAiOcrScanButton<Map<String, dynamic>>(
                builder: (context, onPressed) {
                  return _buildOptionTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: AppStrings.aDOPScanOrderImageTitle.tr(),
                    subtitle: AppStrings.aDOPScanOrderImageSubtitle.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      onPressed();
                    },
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
                  final extractedOrderInfoModel =
                      ExtractedOrderInfoModel.fromJson(data);
                  final extractedOrderInfo = ExtractedOrderInfoEntity(
                    orderCode: extractedOrderInfoModel.orderCode,
                    orderName: extractedOrderInfoModel.orderName,
                    contactName: extractedOrderInfoModel.contactName,
                    contactPhone: extractedOrderInfoModel.contactPhone,
                    address: extractedOrderInfoModel.address,
                  );
                  _applyExtractedOrderInfoIntoForm(
                    context: parentContext,
                    extractedOrderInfo: extractedOrderInfo,
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildOptionTile(
                icon: Icons.insert_drive_file_outlined,
                title: AppStrings.aDOPImportJsonTitle.tr(),
                subtitle: AppStrings.aDOPImportJsonSubtitle.tr(),
                onTap: () {
                  Navigator.pop(context);
                  _showJsonImportBottomSheet(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJsonImportBottomSheet({required BuildContext context}) async {
    final List<ExtractedOrderInfoEntity>? orders = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const JsonImportBottomSheet(),
    );

    if (orders != null && orders.isNotEmpty) {
      setState(() {
        _importedOrderInfos = [
          ..._importedOrderInfos,
          ...orders.where(
            (order) => !_importedOrderInfos.any(
              ((e) => e.orderCode == order.orderCode),
            ),
          ),
        ];
      });
    }
  }

  // Widget dùng chung để dựng từng Option Card
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // Thay đổi màu hiệu ứng lan tỏa và nhấn giữ sang tông nhạt của AppColors.primary
          splashColor: AppColors.primary.withAlpha((0.12 * 255).round()),
          highlightColor: AppColors.primary.withAlpha((0.08 * 255).round()),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Khung Icon vuông bo góc màu xanh nhạt
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),

                // Title và Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Icon mũi tên chuyển hướng
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm phụ trợ xây dựng dòng thông tin
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _runInference(String ocrText) async {
    if (_isGenerating) {
      throw Exception(AppStrings.aDOPAIProcessingPreviousRequestError.tr());
    }
    try {
      _isGenerating = true;
      final cleanOcrText = ocrText
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      if (cleanOcrText.isEmpty) {
        throw Exception(AppStrings.aDOPOcrContentNotDetectedError.tr());
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

  Widget _buildImportedOrdersSection({required BuildContext context}) {
    return ImportedOrders(
      context: context,
      deliveryRoute: _deliveryRoute!,
      extractedOrderInfos: _importedOrderInfos,
      onItemSelected: (selectedExtractedOrderInfo) {
        _applyExtractedOrderInfoIntoForm(
          context: context,
          extractedOrderInfo: selectedExtractedOrderInfo,
        );
      },
      onClose: _closeImportedOrdersSection,
    );
  }

  void _closeImportedOrdersSection() {
    AppDialogUtils.showSuccess(
      context: context,
      title: AppStrings.aDOPCloseImportedOrdersDialogTitle.tr(),
      subtitle: AppStrings.aDOPCloseImportedOrdersDialogSubtitle.tr(),
      actions: [
        SmgoButton(
          isOutlined: true,
          text: AppStrings.aDOPCancelButtonLabel.tr(),
          primaryColor: AppColors.primary,
          onPressed: () {
            context.pop();
          },
        ),
        SmgoButton(
          primaryColor: AppColors.primary,
          text: AppStrings.aDOPConfirmButtonLabel.tr(),
          onPressed: () {
            setState(() {
              _importedOrderInfos.clear();
            });
            context.pop();
          },
        ),
      ],
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
          _buildSectionHeader(
            Icons.qr_code,
            AppStrings.aDOPOrderInfoSectionTitle.tr(),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildInputField(
                label: AppStrings.aDOPOrderCodeFieldLabel.tr(),
                placeholder: AppStrings.aDOPOrderCodePlaceholder.tr(),
                onChanged: addDeliveryOrderFormCubit.orderCodeInputChanged,
                controller: _orderCodeInputController,
                isLocked: _lockedFields.contains(LockableField.orderCode),
                onLockToggle: () {
                  setState(() {
                    if (_lockedFields.contains(LockableField.orderCode)) {
                      _lockedFields.remove(LockableField.orderCode);
                    } else {
                      _lockedFields.add(LockableField.orderCode);
                    }
                  });
                },
              ),
              if (addDeliveryOrderFormCubit.state.orderCodeInput.displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: AppStrings.aDOPOrderCodeRequiredError.tr(),
                ),
              ],
              if (addDeliveryOrderFormCubit.isOrderCodeDuplicated(
                existingDeliveryOrders: _deliveryRoute!.orders,
              )) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: AppStrings.aDOPOrderCodeAlreadyExistsError.tr(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: AppStrings.aDOPProductNameFieldLabel.tr(),
            placeholder: AppStrings.aDOPProductNamePlaceholder.tr(),
            onChanged: addDeliveryOrderFormCubit.orderNameInputChanged,
            controller: _orderNameInputController,
            isLocked: _lockedFields.contains(LockableField.orderName),
            onLockToggle: () {
              setState(() {
                if (_lockedFields.contains(LockableField.orderName)) {
                  _lockedFields.remove(LockableField.orderName);
                } else {
                  _lockedFields.add(LockableField.orderName);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.aDOPOrderImageLabel.tr(),
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildImagePickerList(
            isReset: addDeliveryOrderFormCubit.state.orderMediaId == null,
            onImagesChanged: (images) {
              addDeliveryOrderFormCubit.orderMediaIdChanged(
                images.isNotEmpty ? images[0].id : null,
              );
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
          _buildSectionHeader(
            Icons.person_outline,
            AppStrings.aDOPRecipientInfoSectionTitle.tr(),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildInputField(
                label: AppStrings.aDOPRecipientNameFieldLabel.tr(),
                placeholder: AppStrings.aDOPRecipientNamePlaceholder.tr(),
                onChanged: addDeliveryOrderFormCubit.contactNameInputChanged,
                controller: _contactNameInputController,
                isLocked: _lockedFields.contains(LockableField.contactName),
                onLockToggle: () {
                  setState(() {
                    if (_lockedFields.contains(LockableField.contactName)) {
                      _lockedFields.remove(LockableField.contactName);
                    } else {
                      _lockedFields.add(LockableField.contactName);
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
                M3ErrorText(
                  errorText: AppStrings.aDOPRecipientNameRequiredError.tr(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildInputField(
                label: AppStrings.aDOPPhoneNumberFieldLabel.tr(),
                placeholder: AppStrings.aDOPPhoneNumberPlaceholder.tr(),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  addDeliveryOrderFormCubit.contactPhoneInputChanged(value);
                  context.read<GetLocationSuggestionsCubit>().call(
                    contactPhone: value,
                    address: addDeliveryOrderFormCubit.state.addressInput.value,
                  );
                },
                controller: _contactPhoneInputController,
                isLocked: _lockedFields.contains(LockableField.contactPhone),
                onLockToggle: () {
                  setState(() {
                    if (_lockedFields.contains(LockableField.contactPhone)) {
                      _lockedFields.remove(LockableField.contactPhone);
                    } else {
                      _lockedFields.add(LockableField.contactPhone);
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
                  M3ErrorText(
                    errorText: AppStrings.aDOPPhoneNumberRequiredError.tr(),
                  ),
                if (addDeliveryOrderFormCubit
                        .state
                        .contactPhoneInput
                        .displayError ==
                    ContactPhoneInputValidationError.invalid)
                  M3ErrorText(
                    errorText: AppStrings.aDOPInvalidPhoneNumberError.tr(),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildInputField(
                label: AppStrings.aDOPRecipientAddressFieldLabel.tr(),
                placeholder: AppStrings.aDOPRecipientAddressPlaceholder.tr(),
                onChanged: (value) {
                  addDeliveryOrderFormCubit.addressInputChanged(value);
                  context.read<GetLocationSuggestionsCubit>().call(
                    contactPhone:
                        addDeliveryOrderFormCubit.state.contactPhoneInput.value,
                    address: value,
                  );
                },
                controller: _addressInputController,
                isLocked: _lockedFields.contains(LockableField.address),
                onLockToggle: () {
                  setState(() {
                    if (_lockedFields.contains(LockableField.address)) {
                      _lockedFields.remove(LockableField.address);
                    } else {
                      _lockedFields.add(LockableField.address);
                    }
                  });
                },
              ),
              if (addDeliveryOrderFormCubit.state.addressInput.displayError !=
                  null) ...[
                SizedBox(height: 4),
                M3ErrorText(
                  errorText: AppStrings.aDOPRecipientAddressRequiredError.tr(),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          BlocBuilder<GetLocationSuggestionsCubit, GetLocationSuggestionsState>(
            builder: (context, state) {
              final addDeliveryOrderFormCubit = context
                  .read<AddDeliveryOrderFormCubit>();
              final suggestions = state is GetLocationSuggestionsDone
                  ? state.locationSuggestions.data
                  : <LocationEntity>[];
              return _buildSavedAddressSuggestions(
                selectedIndex: suggestions.indexWhere(
                  (suggestion) =>
                      suggestion.id ==
                      addDeliveryOrderFormCubit.state.appliedLocationId,
                ),
                isLoading: state is GetLocationSuggestionsLoading,
                suggestions: suggestions,
                onItemSelected: (value) {
                  if (addDeliveryOrderFormCubit.state.appliedLocationId ==
                      value) {
                    addDeliveryOrderFormCubit.appliedLocationIdChanged(null);
                    addDeliveryOrderFormCubit.locationInputChanged(null);
                    return;
                  }
                  addDeliveryOrderFormCubit.appliedLocationIdChanged(value);
                  final location = suggestions
                      .where((sug) => sug.id == value)
                      .first
                      .location;
                  addDeliveryOrderFormCubit.locationInputChanged(
                    PointUsecaseParam(x: location.x, y: location.y),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            AppStrings.aDOPRecipientLocationLabel.tr(),
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          BlocBuilder<GetLocationSuggestionsCubit, GetLocationSuggestionsState>(
            builder: (context, state) => Column(
              children: [
                _buildMapPreview(
                  mapMode:
                      addDeliveryOrderFormCubit.state.appliedLocationId != null
                      ? MapMode.view
                      : MapMode.select,
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
                if (addDeliveryOrderFormCubit
                        .state
                        .locationInput
                        .displayError !=
                    null) ...[
                  SizedBox(height: 4),
                  M3ErrorText(
                    errorText: AppStrings.aDOPSelectRecipientLocationError.tr(),
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
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 48, 24, 24),
              fontSize: 13,
            ),
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
    bool isReset = false,
    required void Function(List<GridImageItem> images) onImagesChanged,
  }) {
    return M3ImagePickerGrid(
      reset: isReset,
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
                  children: [
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
                            AppStrings.aDOPLocationSuggestionTitle.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            AppStrings.aDOPLocationSuggestionSubtitle.tr(),
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        AppStrings.aDOPNoLocationSuggestion.tr(),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  )
                else
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
                                                child: Text(
                                                  AppStrings.aDOPBestChoiceLabel
                                                      .tr(),
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
                                              enabled:
                                                  state is GetProfileLoading,
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
                                                          state.profile?.id
                                                      ? AppStrings
                                                            .aDOPSavedByMeLabel
                                                            .tr()
                                                      : AppStrings
                                                            .aDOPCommunityLabel
                                                            .tr(),
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
