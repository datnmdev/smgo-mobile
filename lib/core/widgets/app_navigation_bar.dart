import 'package:flutter/material.dart';

class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy màu chủ đạo dựa theo theme màu xanh của ứng dụng từ ảnh (Shipgo)
    final Color primaryGreen = const Color(
      0xFF2E8B57,
    ); // Hoặc mã màu xanh tương đương trong ảnh
    final Color backgroundColor = const Color(
      0xFF133822,
    ); // Màu nền tối tone xanh sâu cho bar (hoặc dùng Colors.white tùy thiết kế)

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // Hoặc nền tối nếu muốn hợp mood app
        selectedItemColor: const Color(
          0xFF238c55,
        ), // Màu xanh lá sáng nổi bật giống logo Shipgo
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Đã lưu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route),
            activeIcon: Icon(Icons.map),
            label: 'Lộ trình',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
