import 'package:flutter/material.dart';

enum AppDialogType { success, error, warning, info }

class AppDialogUtils {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? content,
    List<Widget>? actions,
    IconData? iconData,
    Color? primaryColor,
    bool barrierDismissible = true,
    AppDialogType type = AppDialogType.success,
  }) {
    final Color defaultColor;
    final IconData defaultIcon;

    switch (type) {
      case AppDialogType.success:
        defaultColor = const Color(0xFF1B8A49);
        defaultIcon = Icons.check_circle_outline_rounded;
        break;
      case AppDialogType.error:
        defaultColor = const Color(0xFFD32F2F);
        defaultIcon = Icons.error_outline_rounded;
        break;
      case AppDialogType.warning:
        defaultColor = const Color(0xFFED6C02);
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case AppDialogType.info:
        defaultColor = const Color(0xFF0288D1);
        defaultIcon = Icons.info_outline_rounded;
        break;
    }

    final themeColor = primaryColor ?? defaultColor;
    final icon = iconData ?? defaultIcon;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(icon, color: themeColor, size: 64),
                const SizedBox(height: 16),

                // Tiêu đề (Bắt buộc)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),

                // Phụ đề (Tùy chọn)
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],

                // Phần thân tùy chọn (Truyền Widget bất kỳ vào đây)
                if (content != null) ...[const SizedBox(height: 20), content],

                // Danh sách nút hành động tùy chọn ở dưới
                if (actions != null && actions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        actions
                            .map((action) => Expanded(child: action))
                            .expand(
                              (widget) => [widget, const SizedBox(width: 8)],
                            )
                            .toList()
                          ..removeLast(), // Thêm khoảng cách giữa các nút
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper cho Success Dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showCustomDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      content: content,
      actions: actions,
      barrierDismissible: barrierDismissible,
      type: AppDialogType.success,
    );
  }

  // Helper cho Error Dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showCustomDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      content: content,
      actions: actions,
      barrierDismissible: barrierDismissible,
      type: AppDialogType.error,
    );
  }
}
