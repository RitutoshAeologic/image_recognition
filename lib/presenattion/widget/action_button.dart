import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_recognition/core/constant/app_colors.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool enabled;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.enabled   = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.accent : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isPrimary ? Colors.transparent : AppColors.border,
                width: 1.5),
            boxShadow: (isPrimary && enabled)
                ? [
              BoxShadow(
                  color: AppColors.accent.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: isPrimary ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
