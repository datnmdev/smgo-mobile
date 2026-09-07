import 'package:flutter/material.dart';

class SmgoLoading extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget icon;

  const SmgoLoading({
    super.key,
    this.title = "Đang xử lý...",
    this.subtitle = "Vui lòng chờ trong giây lát",
    this.icon = const Icon(
      Icons.inventory_2_outlined,
      size: 12,
      color: Colors.green,
    ),
  });

  @override
  State<SmgoLoading> createState() => _SmgoLoadingState();
}

class _SmgoLoadingState extends State<SmgoLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Khởi tạo AnimationController để làm hiệu ứng xoay lặp lại
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phần Loading Animation và Icon ở giữa
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vòng tròn loading có animation xoay
                  RotationTransition(
                    turns: _controller,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                      backgroundColor: Colors.green.withAlpha(
                        (0.15 * 255).round(),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  widget.icon,
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Tiêu đề động
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1E22),
              ),
            ),
            const SizedBox(height: 8),
            // Phụ đề động
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8F9098)),
            ),
          ],
        ),
      ),
    );
  }
}
