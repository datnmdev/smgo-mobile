import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/features/person/presentation/widgets/cancel_subscription_card.dart';
import 'package:smgo/shared/helpers/plan_ui_helper.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/utils/app_url_utils.dart';

class PlanDetailBottomSheet extends StatefulWidget {
  final SubscriptionEntity? currentPlan;
  const PlanDetailBottomSheet({super.key, this.currentPlan});

  @override
  State<PlanDetailBottomSheet> createState() => _PlanDetailBottomSheetState();
}

class _PlanDetailBottomSheetState extends State<PlanDetailBottomSheet> {
  late SubscriptionEntity? _currentPlan;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.currentPlan;
  }

  @override
  void didUpdateWidget(covariant PlanDetailBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPlan != widget.currentPlan) {
      setState(() {
        _currentPlan = widget.currentPlan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo (Drag handle) ở trên cùng
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Tiêu đề & Nút đóng (X)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.pDBSTitle.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Khối thông tin gói hiện tại
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: PlanUiHelper.getPlanIconBgColor(
                    _currentPlan?.productId,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  PlanUiHelper.getPlanIcon(_currentPlan?.productId),
                  color: PlanUiHelper.getPlanIconColor(_currentPlan?.productId),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin tên gói
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.pDBSCurrentPlanLabel.tr(),
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      PlanUiHelper.getPlanName(_currentPlan?.productId),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge "Đang hoạt động"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  PlanUiHelper.getStatusName(_currentPlan?.status),
                  style: TextStyle(
                    color: PlanUiHelper.getStatusColor(
                      _currentPlan?.status,
                      AppColors.primary,
                    ),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Dòng: Ngày đăng ký
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: AppStrings.pDBSRegistrationDateLabel.tr(),
            value: _currentPlan?.startsAt != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(_currentPlan!.startsAt).toString()
                : '---',
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Dòng: Ngày hết hạn
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            title: AppStrings.pDBSExpirationDateLabel.tr(),
            value: _currentPlan?.productId == ProductId.basic.value
                ? AppStrings.pDBSNoExpirationLabel.tr()
                : _currentPlan?.expiresAt != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(_currentPlan!.expiresAt!).toString()
                : '---',
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          if (_currentPlan?.productId != ProductId.basic.value) ...[
            SizedBox(height: 8),
            CancelSubscriptionCard(
              onTap: () {
                AppUrlUtils.launchLink(
                  'https://play.google.com/store/account/subscriptions'
                  '?sku=${_currentPlan?.productId}'
                  '&package=${Env.packageName}',
                );
              },
            ),
          ],

          // Khối Cảnh báo / Nạp tiền vào tài khoản thanh toán
          if (_currentPlan?.status == SubscriptionStatus.inGracePeriod.value ||
              _currentPlan?.status == SubscriptionStatus.onHold.value) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFEBAD)),
              ),
              child: Row(
                children: [
                  // Icon Cảnh báo
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  // Nội dung cảnh báo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.pDBSPaymentDueWarningTitle.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppStrings.pDBSPaymentDueWarningContent.tr(),
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget dùng chung cho từng dòng thông tin
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00875A), size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
