import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_strings.dart';

class PremiumBannerCard extends StatelessWidget {
  const PremiumBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFD3E7DA), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF6CBD8F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const Positioned(
                top: -3,
                right: -2,
                child: Icon(Icons.star, size: 10, color: Color(0xFF6CBD8F)),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.pBCUsingHighestPackageTitle.tr(),
                  style: TextStyle(
                    fontSize: 14, // Giảm từ 16 xuống 14
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF008A3C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.pBCPackageBenefitsDescription.tr(),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF555555),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.emoji_events, color: Color(0xFF008A3C), size: 26),
        ],
      ),
    );
  }
}
