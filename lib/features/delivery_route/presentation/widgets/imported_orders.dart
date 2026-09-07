import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/extracted_order_info_entity.dart';

class ImportedOrders extends StatefulWidget {
  final BuildContext context;
  final List<ExtractedOrderInfoEntity> extractedOrderInfos;
  final DeliveryRouteEntity deliveryRoute;
  final void Function(ExtractedOrderInfoEntity selectedExtractedOrderInfo)?
  onItemSelected;
  final VoidCallback? onClose;

  const ImportedOrders({
    super.key,
    required this.context,
    required this.extractedOrderInfos,
    required this.deliveryRoute,
    this.onItemSelected,
    this.onClose,
  });

  @override
  State<ImportedOrders> createState() => _ImportedOrdersState();
}

class _ImportedOrdersState extends State<ImportedOrders> {
  int selectedIndex = -1;
  late List<ExtractedOrderInfoEntity> _extractedOrderInfos;
  late DeliveryRouteEntity _deliveryRoute;

  @override
  void initState() {
    super.initState();
    _extractedOrderInfos = widget.extractedOrderInfos;
    _deliveryRoute = widget.deliveryRoute;
  }

  @override
  void didUpdateWidget(covariant ImportedOrders oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.extractedOrderInfos != widget.extractedOrderInfos) {
        _extractedOrderInfos = widget.extractedOrderInfos;
        if (selectedIndex >= _extractedOrderInfos.length) {
          selectedIndex = -1;
        }
      }

      if (oldWidget.deliveryRoute != widget.deliveryRoute) {
        _deliveryRoute = widget.deliveryRoute;
      }
    });
  }

  void _handleApply() {
    if (selectedIndex >= 0 && selectedIndex < _extractedOrderInfos.length) {
      final selectedItem = _extractedOrderInfos[selectedIndex];
      widget.onItemSelected?.call(selectedItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.importedOrdersAppliedToFormSnackBarContent.tr(),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    final bool isApplyEnabled =
        _extractedOrderInfos.isNotEmpty && selectedIndex != -1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: primaryColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.importedOrdersImportedOrdersFromJsonContent.tr(
                        namedArgs: {
                          'quantity': _extractedOrderInfos.length.toString(),
                        },
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.importedOrdersSelectOrderToApplyContent.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              OutlinedButton(
                onPressed: isApplyEnabled ? _handleApply : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isApplyEnabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.importedOrdersApplyButtonLabel.tr(),
                  style: TextStyle(
                    color: isApplyEnabled ? primaryColor : Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: widget.onClose,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.importedOrdersCloseButtonLabel.tr(),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danh sách cuộn ngang
          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _extractedOrderInfos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final order = _extractedOrderInfos[index];
                final isSelected = selectedIndex == index;
                final bool isUsed = _deliveryRoute.orders.any(
                  (e) => e.orderCode == order.orderCode,
                );
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedIndex == index) {
                        selectedIndex = -1;
                      } else {
                        selectedIndex = index;
                      }
                    });
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.02 * 255).round()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                order.orderCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isUsed
                                    ? Colors.grey.shade200
                                    : primaryColor.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isUsed
                                    ? AppStrings.importedOrdersUsedStatusLabel
                                          .tr()
                                    : AppStrings.importedOrdersUnusedStatusLabel
                                          .tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isUsed
                                      ? Colors.grey.shade600
                                      : primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Tên người nhận
                        Text(
                          order.contactName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Số điện thoại
                        Text(
                          order.contactPhone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Địa chỉ
                        Text(
                          order.address,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
