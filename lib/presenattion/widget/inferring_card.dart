import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_recognition/core/constant/app_colors.dart';

class InferringCard extends StatelessWidget {
  final File file;
  const InferringCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.accent.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.contain),
            Container(color: Colors.black.withOpacity(0.45)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                      AlwaysStoppedAnimation(AppColors.accentLight)),
                ),
                const SizedBox(height: 16),
                const Text('Analyzing…',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Running on-device inference',
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
