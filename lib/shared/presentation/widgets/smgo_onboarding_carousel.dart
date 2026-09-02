import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_colors.dart';

class SmGoOnboardingCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final List<Widget>? actions;

  const SmGoOnboardingCarousel({
    super.key,
    required this.imageUrls,
    this.actions,
  });

  @override
  State<SmGoOnboardingCarousel> createState() => _SmGoOnboardingCarouselState();
}

class _SmGoOnboardingCarouselState extends State<SmGoOnboardingCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  Timer? _debounceTimer;

  int _currentPage = 0;

  static const Color primaryGreen = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  int _getRealIndex(int index) {
    if (widget.imageUrls.isEmpty) return 0;
    final int remainder = index % widget.imageUrls.length;
    return remainder < 0 ? remainder + widget.imageUrls.length : remainder;
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteraction() {
    _autoScrollTimer?.cancel();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _startAutoScroll();
    });
  }

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    return AssetImage(url);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _debounceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int activeIndex = _getRealIndex(_currentPage);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Carousel Ảnh toàn màn hình
          Listener(
            onPointerDown: (_) => _onUserInteraction(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final imageIndex = _getRealIndex(index);
                final imagePath = widget.imageUrls[imageIndex];

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _getImageProvider(imagePath),
                      fit: BoxFit.cover, // Phủ toàn bộ màn hình
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Nội dung phía trên (Pagination Dots + Actions)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        height: 8,
                        width: activeIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: activeIndex == index
                              ? primaryGreen
                              : Colors.white.withAlpha((0.8 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.25 * 255).round(),
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Đổ các nút hành động (actions) được truyền từ bên ngoài hoặc dùng nút mặc định
                  ...?widget.actions ?? _buildDefaultActions(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [];
  }
}
