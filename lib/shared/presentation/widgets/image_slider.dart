import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_strings.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final Duration autoScrollDuration;
  final bool isLoading;
  final String? defaultImageUrl;
  final bool enableAutoScroll;

  const ImageSlider({
    super.key,
    required this.imageUrls,
    this.autoScrollDuration = const Duration(seconds: 4),
    this.isLoading = false,
    this.defaultImageUrl = 'https://via.placeholder.com/600x300?text=No+Image',
    this.enableAutoScroll = true,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  List<String> get _effectiveImages {
    if (widget.imageUrls.isNotEmpty) {
      return widget.imageUrls;
    }
    if (widget.defaultImageUrl != null && widget.defaultImageUrl!.isNotEmpty) {
      return [widget.defaultImageUrl!];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant ImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.enableAutoScroll != widget.enableAutoScroll ||
        oldWidget.autoScrollDuration != widget.autoScrollDuration ||
        oldWidget.imageUrls != widget.imageUrls) {
      _resetAndRestart();
    }
  }

  void _resetAndRestart() {
    _currentIndex = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (!widget.enableAutoScroll ||
        widget.isLoading ||
        _effectiveImages.length <= 1) {
      return;
    }

    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % _effectiveImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayImages = _effectiveImages;

    return SizedBox(
      height: 200,
      child: widget.isLoading
          ? const _ShimmerSkeleton(height: 200, borderRadius: 16)
          : displayImages.isEmpty
          ? const SizedBox.shrink()
          : Stack(
              children: [
                // Swipeable Image View
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.grey[100],
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: displayImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        // Restarts timer when user manually swipes
                        _startAutoPlay();
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          displayImages[index],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    AppStrings.iSErrorLoadImageText.tr(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Dynamic Page Counter Badge
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.6 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentIndex + 1}/${displayImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ShimmerSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const _ShimmerSkeleton({
    required this.height,
    this.width,
    this.borderRadius = 16,
  });

  @override
  State<_ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<_ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 3), -0.3),
              end: Alignment(1.0 + (_controller.value * 3), 0.3),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}
