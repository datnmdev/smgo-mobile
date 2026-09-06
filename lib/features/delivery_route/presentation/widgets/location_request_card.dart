import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_colors.dart';

class LocationRequestCard extends StatelessWidget {
  final VoidCallback? onRequestLocation;
  final bool isLoading;

  const LocationRequestCard({
    super.key,
    this.onRequestLocation,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: primaryGreen, size: 22),
              SizedBox(width: 8),
              Text(
                'Yêu cầu lấy vị trí người nhận',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nút hành động chính
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRequestLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                disabledBackgroundColor: primaryGreen.withAlpha(
                  (0.6 * 255).round(),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.link, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Yêu cầu lấy vị trí',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F9F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                _StepRow(
                  stepNumber: '1',
                  icon: Icons.link,
                  text: 'Nhấn "Yêu cầu lấy vị trí" để tạo link.',
                ),
                SizedBox(height: 12),
                _StepRow(
                  stepNumber: '2',
                  icon: Icons.near_me_outlined,
                  text: 'Gửi link cho người nhận và yêu cầu họ cấp vị trí.',
                ),
                SizedBox(height: 12),
                _StepRow(
                  stepNumber: '3',
                  icon: Icons.my_location,
                  text:
                      'Truy cập lại link đã gửi để nhận vị trí và xem chỉ đường chính xác.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String stepNumber;
  final IconData icon;
  final String text;

  const _StepRow({
    required this.stepNumber,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF008744);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: primaryGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
