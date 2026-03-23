import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_recognition/core/constant/app_colors.dart';
import 'package:image_recognition/domain/model/prediction.dart';
import 'package:image_recognition/presenattion/controller/recognition_controller.dart';
import 'package:image_recognition/presenattion/widget/action_button.dart';
import 'package:image_recognition/presenattion/widget/empty_image_card.dart';
import 'package:image_recognition/presenattion/widget/image_preview_card.dart';
import 'package:image_recognition/presenattion/widget/inferring_card.dart';
import 'package:image_recognition/presenattion/widget/model_status_badge.dart';
import 'package:image_recognition/presenattion/widget/picking_card.dart';
import 'package:image_recognition/presenattion/widget/prediction_card.dart';


class RecognitionScreen extends StatelessWidget {
  RecognitionScreen({super.key});

  final controller = Get.find<RecognitionController>();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Obx(() => _buildBody()),
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
  );

  Widget _buildBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildImageArea(),
                  const SizedBox(height: 24),
                  if (controller.isDone && controller.predictions.isNotEmpty) ...[
                    _buildResultsHeader(),
                    const SizedBox(height: 12),
                    _buildPredictionsList(),
                    const SizedBox(height: 24),
                  ]else if(controller.isDone && controller.predictions.isEmpty)...[
                    Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 16),
                      const SizedBox(width: 8),
                      Text('Detection Results',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.accentGlow,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('${controller.predictions.length} found',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accentLight,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                    const SizedBox(height: 12),
                  ],
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accentGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detection AI',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3)),
                Text('MobileNet v2 · Offline',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3)),
              ],
            ),
            const Spacer(),
            ModelStatusBadge(isLoaded: controller.modelLoaded),
          ],
        ),
      ),
    );
  }

  // ── Image Area ───────────────────────────────
  // KEY FIX: child key encodes BOTH the image path AND current state,
  // so AnimatedSwitcher always detects a real change and plays the
  // transition every time you pick a new image or inference starts.
  Widget _buildImageArea() {
    final state = controller.state.value;
    final file  = controller.image.value;

    final Widget child;
    final Key   childKey;

    if (state == RecognitionState.picking) {
      childKey = const ValueKey('picking');
      child    = const PickingCard();
    } else if (state == RecognitionState.inferring && file != null) {
      // Show new image immediately with an overlay spinner.
      childKey = ValueKey('inferring_${file.path}');
      child    = InferringCard(file: file);
    } else if (file != null) {
      childKey = ValueKey('preview_${file.path}');
      child    = ImagePreviewCard(file: file);
    } else {
      childKey = const ValueKey('empty');
      child    = const EmptyImageCard();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child),
      ),
      child: KeyedSubtree(key: childKey, child: child),
    );
  }

  // ── Results Header ───────────────────────────
  Widget _buildResultsHeader() {
    return Row(
      children: [
        const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 16),
        const SizedBox(width: 8),
        Text('Detection Results',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.2)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: AppColors.accentGlow,
              borderRadius: BorderRadius.circular(20)),
          child: Text('${controller.predictions.length} found',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Predictions List ─────────────────────────
  Widget _buildPredictionsList() {
    return Column(
      children: List.generate(controller.predictions.length, (i) {
        final p = controller.predictions[i];
        return PredictionCard(prediction: p, rank: i + 1, isTop: i == 0);
      }),
    );
  }

  // ── Action Buttons ───────────────────────────
  Widget _buildActionButtons() {
    final busy = controller.isBusy;
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            enabled: !busy,
            onTap: () => controller.pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            isPrimary: true,
            enabled: !busy,
            onTap: () => controller.pickImage(ImageSource.camera),
          ),
        ),
      ],
    );
  }
}



 