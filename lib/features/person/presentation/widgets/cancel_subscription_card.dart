import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_strings.dart';

class CancelSubscriptionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const CancelSubscriptionCard({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Material(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.block_outlined,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.cancelSubscriptionCardTitle.tr(),
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        AppStrings.cancelSubscriptionCardSubtitle.tr(),
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD32F2F),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFD32F2F),
                        size: 18,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
