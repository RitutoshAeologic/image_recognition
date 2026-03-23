import 'package:flutter/material.dart';
import 'package:image_recognition/core/constant/app_colors.dart';
import 'package:image_recognition/domain/model/prediction.dart';
class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final int rank;
  final bool isTop;
  const PredictionCard(
      {super.key, required this.prediction, required this.rank, required this.isTop});

  @override
  Widget build(BuildContext context) {
    final confidence = prediction.confidence;
    final percent    = (confidence * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop ? AppColors.accentGlow : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isTop ? AppColors.accent.withOpacity(0.5) : AppColors.border,
            width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: isTop ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text('#$rank',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isTop ? Colors.white : AppColors.textSecondary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(prediction.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ),
                    Text('$percent%',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isTop
                                ? AppColors.accentLight
                                : AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence,
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        isTop ? AppColors.accent : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
