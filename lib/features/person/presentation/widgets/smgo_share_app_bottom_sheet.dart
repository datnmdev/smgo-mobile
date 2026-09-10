import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smgo/core/network/external_links.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';

class SmGoShareAppBottomSheet extends StatelessWidget {
  const SmGoShareAppBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.sSABSHeaderTitle.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.sSABSHeaderContent.tr(),
                        style: const TextStyle(
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
            _buildStoreTile(
              context: context,
              icon: Icons.android,
              iconColor: const Color(0xFF34A853),
              iconBackgroundColor: const Color(0xFFEAF7EE),
              title: AppStrings.sSABSGooglePlayTitle.tr(),
              subtitle: AppStrings.sSABSGooglePlaySubtitle.tr(),
              onTap: () => _shareStoreLink(
                context: context,
                storeName: AppStrings.sSABSGooglePlayTitle.tr(),
                url: ExternalLinks.googlePlayStore,
              ),
            ),
            // const SizedBox(height: 12),
            // _buildStoreTile(
            //   context: context,
            //   icon: Icons.apple,
            //   iconColor: Colors.black87,
            //   iconBackgroundColor: const Color(0xFFF1F5F9),
            //   title: AppStrings.sSABSAppStoreTitle.tr(),
            //   subtitle: AppStrings.sSABSAppStoreSubtitle.tr(),
            //   onTap: () => _shareStoreLink(
            //     context: context,
            //     storeName: AppStrings.sSABSAppStoreTitle.tr(),
            //     url: ExternalLinks.appStore,
            //   ),
            // ),
            // const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _shareStoreLink({
    required BuildContext context,
    required String storeName,
    required String url,
  }) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = renderBox == null
        ? null
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    Navigator.of(context).pop();

    await Future<void>.delayed(const Duration(milliseconds: 150));

    await SharePlus.instance.share(
      ShareParams(
        title: AppStrings.sSABSShareTitle.tr(),
        subject: AppStrings.sSABSShareTitle.tr(),
        text: AppStrings.sSABSShareContent.tr(
          namedArgs: {'store': storeName, 'url': url},
        ),
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Widget _buildStoreTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(
          context,
        ).primaryColor.withAlpha((0.1 * 255).round()),
        highlightColor: Colors.black.withAlpha((0.05 * 255).round()),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 12),
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
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
