import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';

class PlanUiHelper {
  // Các hàm helper
  static String getPlanName(String? productId) {
    if (productId == ProductId.basic.value) {
      return AppStrings.pUHBasicPlanName.tr();
    } else if (productId == ProductId.standard.value) {
      return AppStrings.pUHStandardPlanName.tr();
    } else if (productId == ProductId.plus.value) {
      return AppStrings.pUHPlusPlanName.tr();
    } else if (productId == ProductId.premium.value) {
      return AppStrings.pUHPremiumPlanName.tr();
    } else {
      return AppStrings.pUHUnknownPlanName.tr();
    }
  }

  static String getStatusName(String? status) {
    if (status == SubscriptionStatus.active.value ||
        status == SubscriptionStatus.canceled.value) {
      return AppStrings.pUHActiveStatusName.tr();
    } else if (status == SubscriptionStatus.inGracePeriod.value ||
        status == SubscriptionStatus.onHold.value) {
      return AppStrings.pUHPaymentPendingStatusName.tr();
    } else if (status == SubscriptionStatus.expired.value) {
      return AppStrings.pUHExpiredStatusName.tr();
    } else {
      return AppStrings.pUHUnknownStatusName.tr();
    }
  }

  static Color getStatusColor(String? status, Color defaultColor) {
    if (status == SubscriptionStatus.active.value ||
        status == SubscriptionStatus.canceled.value) {
      return defaultColor;
    } else if (status == SubscriptionStatus.inGracePeriod.value ||
        status == SubscriptionStatus.onHold.value) {
      return Colors.orange;
    } else if (status == SubscriptionStatus.expired.value) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static IconData getPlanIcon(String? productId) {
    if (productId == ProductId.basic.value) {
      return Icons.send_rounded;
    } else if (productId == ProductId.standard.value) {
      return Icons.star_rounded;
    } else if (productId == ProductId.plus.value) {
      return Icons.verified_user_rounded;
    } else if (productId == ProductId.premium.value) {
      return Icons.diamond_rounded;
    }
    return Icons.send_rounded;
  }

  /// Màu chủ đạo (Chữ, Icon, Viền) của từng gói
  static Color getPlanIconColor(String? productId) {
    if (productId == ProductId.basic.value) {
      return const Color(0xFF1E88E5);
    } else if (productId == ProductId.standard.value) {
      return const Color(0xFF00A651);
    } else if (productId == ProductId.plus.value) {
      return const Color(0xFF1976D2);
    } else if (productId == ProductId.premium.value) {
      return const Color(0xFFE65100);
    }
    return const Color(0xFF1E88E5);
  }

  static Color getPlanIconBgColor(String? productId) {
    if (productId == ProductId.basic.value) {
      return const Color(0xFFE3F2FD);
    } else if (productId == ProductId.standard.value) {
      return const Color(0xFFE8F5E9);
    } else if (productId == ProductId.plus.value) {
      return const Color(0xFFE3F2FD);
    } else if (productId == ProductId.premium.value) {
      return const Color(0xFFFFF3E0);
    }
    return const Color(0xFFE3F2FD);
  }
}
