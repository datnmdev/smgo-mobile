import 'package:flutter/material.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';

class PlanUiHelper {
  // Các hàm helper
  static String getPlanName(String? productId) {
    if (productId == ProductId.basic.value) {
      return 'Gói Cơ bản';
    } else if (productId == ProductId.standard.value) {
      return 'Gói Tiêu chuẩn';
    } else if (productId == ProductId.plus.value) {
      return 'Gói Plus';
    } else if (productId == ProductId.premium.value) {
      return 'Gói Cao cấp';
    } else {
      return 'Không xác định';
    }
  }

  static String getStatusName(String? status) {
    if (status == SubscriptionStatus.active.value ||
        status == SubscriptionStatus.canceled.value) {
      return 'Đang hoạt động';
    } else if (status == SubscriptionStatus.inGracePeriod.value ||
        status == SubscriptionStatus.onHold.value) {
      return 'Chờ thanh toán';
    } else if (status == SubscriptionStatus.expired.value) {
      return 'Đã hết hạn';
    } else {
      return 'Không xác định';
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
