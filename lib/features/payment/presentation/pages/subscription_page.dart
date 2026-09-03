import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String activePlanId = 'plus';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A651),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Chọn gói đăng ký',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Banner thông báo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A651),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nâng cấp gói để mở khóa tính năng nâng cao và tăng giới hạn đơn hàng cho mỗi lộ trình.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gói Basic
            _buildPlanCard(
              id: 'basic',
              icon: Icons.send_rounded,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1E88E5),
              title: 'Gói Basic',
              subtitle: 'Phù hợp cho nhu cầu cơ bản',
              price: '0đ/tháng',
              limitText: 'Tối đa 10 đơn / 1 lộ trình giao',
              featureText: 'Hạn chế sử dụng tính năng',
              supportText: 'Hỗ trợ cơ bản',
            ),
            const SizedBox(height: 12),

            // Gói Standard
            _buildPlanCard(
              id: 'standard',
              icon: Icons.star_rounded,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF00A651),
              title: 'Gói Standard',
              subtitle: 'Tối ưu cho nhu cầu vừa phải',
              price: '40.000đ/tháng',
              limitText: 'Tối đa 25 đơn / 1 lộ trình giao',
              featureText: 'Mở khoá toàn bộ tính năng',
              supportText: 'Hỗ trợ ưu tiên',
            ),
            const SizedBox(height: 12),

            // Gói Plus (Gói đang dùng)
            _buildPlanCard(
              id: 'plus',
              icon: Icons.verified_user_rounded,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF00A651),
              title: 'Gói Plus',
              subtitle: 'Đầy đủ tính năng, hiệu quả tối đa',
              price: '80.000đ/tháng',
              limitText: 'Tối đa 50 đơn / 1 lộ trình giao',
              limitHighlight: '50 đơn',
              featureText: 'Mở khoá toàn bộ tính năng',
              supportText: 'Hỗ trợ ưu tiên',
            ),
            const SizedBox(height: 12),

            // Gói Premium
            _buildPlanCard(
              id: 'premium',
              icon: Icons.diamond_rounded,
              iconBgColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFFFA000),
              title: 'Gói Premium',
              subtitle: 'Không giới hạn, không ràng buộc',
              price: '120.000đ/tháng',
              limitText: 'Không giới hạn đơn / 1 lộ trình giao',
              limitHighlight: 'Không giới hạn',
              featureText: 'Mở khóa toàn bộ tính năng',
              supportText: 'Hỗ trợ ưu tiên 24/7',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String price,
    required String limitText,
    String? limitHighlight,
    required String featureText,
    required String supportText,
  }) {
    final bool isActive = activePlanId == id;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF00A651) : Colors.transparent,
              width: isActive ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF00A651),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dòng 1: Giới hạn đơn
              _buildFeatureRow(
                Icons.calendar_today_outlined,
                limitText,
                highlightText: limitHighlight,
              ),
              const SizedBox(height: 8),

              // Dòng 2: Tính năng
              _buildFeatureRow(Icons.lock_outline, featureText),
              const SizedBox(height: 8),

              // Dòng 3: Hỗ trợ
              _buildFeatureRow(Icons.headset_mic_outlined, supportText),
              const SizedBox(height: 12),

              // Nút hành động
              Align(
                alignment: Alignment.centerRight,
                child: isActive
                    ? OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Huỷ gói',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : (id == 'premium'
                          ? OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00A651),
                                side: const BorderSide(
                                  color: Color(0xFF00A651),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Đăng ký gói',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: null, // Disable nút
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Hiện không khả dụng',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )),
              ),
            ],
          ),
        ),

        // Tag "GÓI ĐANG SỬ DỤNG"
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF00A651),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GÓI ĐANG SỬ DỤNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.check_circle, color: Colors.white, size: 12),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, {String? highlightText}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: highlightText != null
              ? RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: _getHighlightedSpans(text, highlightText),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
        ),
      ],
    );
  }

  List<TextSpan> _getHighlightedSpans(String fullText, String highlight) {
    final int startIndex = fullText.indexOf(highlight);
    if (startIndex == -1) {
      return [TextSpan(text: fullText)];
    }
    final int endIndex = startIndex + highlight.length;

    return [
      TextSpan(text: fullText.substring(0, startIndex)),
      TextSpan(
        text: highlight,
        style: const TextStyle(
          color: Color(0xFF00A651),
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(text: fullText.substring(endIndex)),
    ];
  }

  Widget _buildPaymentBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
