import 'package:flutter/material.dart';

class SmgoButton extends StatelessWidget {
  final Widget? child; // Cho phép truyền bất kỳ widget nào
  final String? text; // Tiện ích nhanh nếu chỉ muốn truyền chữ đơn thuần
  final IconData? icon; // Hỗ trợ nhanh icon nếu cần
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color primaryColor;
  final Color? textColor; // Tự đổi màu chữ/icon nếu cần
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDisabled; // Thuộc tính mới bổ sung để vô hiệu hóa nút

  const SmgoButton({
    super.key,
    this.child,
    this.text,
    this.icon,
    required this.onPressed,
    this.isOutlined = false,
    this.primaryColor = const Color(0xFF00796B),
    this.textColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.isDisabled = false, // Mặc định là không disable
  });

  @override
  Widget build(BuildContext context) {
    // Xác định màu khi bị disable
    final actualOnPressed = isDisabled ? null : onPressed;

    // Xử lý màu sắc cho nội dung bên trong khi disable
    Color getContentColor() {
      if (isDisabled) {
        return Colors.grey.shade500;
      }
      return isOutlined ? primaryColor : (textColor ?? Colors.white);
    }

    // Xác định nội dung bên trong nút
    Widget buildButtonContent() {
      if (child != null) return child!;

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: getContentColor(), size: 20),
            const SizedBox(width: 8),
            Text(
              text ?? '',
              style: TextStyle(
                color: getContentColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }

      return Text(
        text ?? '',
        style: TextStyle(
          color: getContentColor(),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: actualOnPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled ? Colors.grey.shade400 : primaryColor,
            width: 1.5,
          ),
          shape: shape,
          padding: padding,
        ),
        child: buildButtonContent(),
      );
    }

    return ElevatedButton(
      onPressed: actualOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey.shade200 : primaryColor,
        elevation: 0,
        shape: shape,
        padding: padding,
      ),
      child: buildButtonContent(),
    );
  }
}
