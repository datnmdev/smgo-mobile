import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';

class SubscriptionError extends StatelessWidget {
  final VoidCallback? onRetry;

  const SubscriptionError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Phần hình minh họa (Kích thước thu nhỏ: 150x120)
            const CloudErrorIllustration(primaryColor: primaryColor),

            const SizedBox(height: 20),

            // 2. Tiêu đề (Size: 17px)
            Text(
              AppStrings.subscriptionErrorTitle.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E252D),
              ),
            ),

            const SizedBox(height: 8),

            // 3. Nội dung mô tả (Size: 13px)
            Text(
              AppStrings.subscriptionErrorContent.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 24),

            // 4. Nút Tải lại (Giảm chiều cao xuống 42px & giới hạn chiều rộng 180px)
            SizedBox(
              width: 180,
              height: 42,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: primaryColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: primaryColor, size: 18),
                    SizedBox(width: 6),
                    Text(
                      AppStrings.subscriptionErrorRetryBtnLabel.tr(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CloudErrorIllustration extends StatelessWidget {
  final Color primaryColor;

  const CloudErrorIllustration({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nền mờ phía sau
          Positioned(
            top: 8,
            child: Container(
              width: 125,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F9F5),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),

          // Hình đám mây vẽ bằng CustomPaint
          CustomPaint(
            size: const Size(120, 75),
            painter: _CloudPainter(
              color: primaryColor.withAlpha((0.5 * 255).round()),
            ),
          ),

          // Các tia phát sáng phía trên bên trái
          Positioned(
            top: 16,
            left: 24,
            child: Row(
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 2.5,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: 2.5,
                    height: 9,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vòng tròn nhỏ góc trên bên phải
          Positioned(
            top: 22,
            right: 20,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withAlpha((0.4 * 255).round()),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Icon chấm cảm (Lỗi) ở giữa
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
          ),

          // Icon x màu xanh phía dưới bên phải đám mây
          Positioned(
            bottom: 16,
            right: 18,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              child: Icon(Icons.close_rounded, size: 14, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter vẽ viền đám mây đơn giản
class _CloudPainter extends CustomPainter {
  final Color color;

  _CloudPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.8,
      size.width * 0.05,
      size.height * 0.4,
      size.width * 0.25,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.05,
      size.width * 0.75,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.4,
      size.width * 0.95,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.8,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
