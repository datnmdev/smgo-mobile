import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/shared/utils/app_url_utils.dart';

class SmGoCommunityBottomSheet extends StatelessWidget {
  const SmGoCommunityBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo (Drag Indicator)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header: Icon + Tiêu đề + Nội dung
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), // Xanh lá nhạt
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF2E7D32), // Xanh lá đậm
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sGCBSHeaderTitle.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppStrings.sGCBSHeaderContent.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danh sách tùy chọn
          _buildOptionTile(
            context: context,
            iconWidget: Image.asset(AppAssets.icFacebook),
            title: AppStrings.sGCBSFacebookTitle.tr(),
            subtitle: AppStrings.sGCBSFacebookSubtitle.tr(),
            onTap: () {
              AppUrlUtils.launchLink(
                'https://www.facebook.com/share/g/1DQgHbxfey/',
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            context: context,
            iconWidget: Image.asset(AppAssets.icZalo),
            title: AppStrings.sGCBSZaloTitle.tr(),
            subtitle: AppStrings.sGCBSZaloSubtitle.tr(),
            onTap: () {
              AppUrlUtils.launchLink('https://zalo.me/g/2367ucr5janxotvrrhpt');
            },
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            context: context,
            iconWidget: Image.asset(AppAssets.icMessenger),
            title: AppStrings.sGCBSMessengerTitle.tr(),
            subtitle: AppStrings.sGCBSMessengerSubtitle.tr(),
            onTap: () {
              AppUrlUtils.launchLink(
                'https://m.me/cm/RHQR-ncMtB6kPOxI/?send_source=cm%3Acopy_invite_link',
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget con tạo từng item lựa chọn
  Widget _buildOptionTile({
    IconData? icon,
    Color? iconColor,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent, // Giữ nền trong suốt cho Material
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(
          context,
        ).primaryColor.withAlpha((0.1 * 255).round()), // Hiệu ứng loang màu nhẹ
        highlightColor: Colors.black.withAlpha(
          (0.05 * 255).round(),
        ), // Màu đổi nhẹ khi giữ tay
        child: Ink(
          // Dùng Ink thay cho Container để không che mất hiệu ứng ripple
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: iconWidget ?? Icon(icon, size: 44, color: iconColor),
                ),
              ),
              const SizedBox(width: 12),

              // Nội dung Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Mũi tên chỉ hướng
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
