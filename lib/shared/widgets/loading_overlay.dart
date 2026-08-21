import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shipgo/core/resources/app_colors.dart';

class BlurLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final double blurAmount;
  final Color barrierColor;

  const BlurLoadingOverlay({
    super.key,
    required this.isLoading,
    this.blurAmount = 5.0,
    this.barrierColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          color: barrierColor,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
