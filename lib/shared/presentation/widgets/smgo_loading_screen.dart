import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smgo/shared/presentation/widgets/smgo_loading.dart';

class SmgoLoadingScreen extends StatelessWidget {
  final bool isLoading;
  final double blurAmount;
  final Color barrierColor;
  final String? title;
  final String? subtitle;
  final Widget? icon;

  const SmgoLoadingScreen({
    super.key,
    required this.isLoading,
    this.blurAmount = 5.0,
    this.barrierColor = Colors.black38,
    this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          color: barrierColor,
          child: SmgoLoading(
            title: title ?? 'Đang xử lý...',
            subtitle: subtitle ?? 'Vui lòng chờ trong giây lát',
            icon:
                icon ??
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 12,
                  color: Colors.green,
                ),
          ),
        ),
      ),
    );
  }
}
