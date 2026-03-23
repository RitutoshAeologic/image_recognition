
import 'package:flutter/material.dart';
import 'package:image_recognition/core/constant/app_colors.dart';

class ModelStatusBadge extends StatelessWidget {
  final bool isLoaded;
  const ModelStatusBadge({required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLoaded ? const Color(0xFF1A3A38) : const Color(0xFF3A2A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isLoaded ? AppColors.success : Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
                color: isLoaded ? AppColors.success : Colors.orange,
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(isLoaded ? 'Ready' : 'Loading',
              style: TextStyle(
                  fontSize: 11,
                  color: isLoaded ? AppColors.success : Colors.orange,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
