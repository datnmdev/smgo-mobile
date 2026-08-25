import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_loading.dart';

class SmgoLoadingScreen extends StatelessWidget {
  final bool isLoading;
  final double blurAmount;
  final Color barrierColor;

  const SmgoLoadingScreen({
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
        child: Container(color: barrierColor, child: SmgoLoading()),
      ),
    );
  }
}
