import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_colors.dart';

class LanguageSelectorButton extends StatelessWidget {
  final String languageCode;
  final VoidCallback onTap;

  const LanguageSelectorButton({
    super.key,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 2,
      shadowColor: Colors.black.withAlpha((0.2 * 255).round()),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                languageCode.toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
