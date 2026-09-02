import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/shared/presentation/widgets/smgo_onboarding_carousel.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmGoOnboardingCarousel(
      imageUrls: [
        AppAssets.carousel1,
        AppAssets.carousel2,
        AppAssets.carousel3,
      ],
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () {
              context.replaceNamed(AppRouteNames.signIn);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Bắt đầu ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
