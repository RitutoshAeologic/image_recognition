import 'package:flutter/material.dart';
import 'package:image_recognition/core/constant/app_colors.dart';

class EmptyImageCard extends StatelessWidget {
  const EmptyImageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: MediaQuery.widthOf(context),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.accentGlow, shape: BoxShape.circle),
            child: const Icon(Icons.image_search_rounded,
                color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 16),
          Text('No image selected',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Take a photo or pick from gallery\nto start recognition',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
