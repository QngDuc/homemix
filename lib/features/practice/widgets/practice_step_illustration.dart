import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/practice_recipe.dart';

class PracticeStepIllustration extends StatelessWidget {
  const PracticeStepIllustration({
    required this.visual,
    required this.stepNumber,
    super.key,
  });

  final PracticeStepVisual visual;
  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    final icon = switch (visual) {
      PracticeStepVisual.prepare => Icons.spa_rounded,
      PracticeStepVisual.brew => Icons.emoji_food_beverage_rounded,
      PracticeStepVisual.measure => Icons.scale_rounded,
      PracticeStepVisual.mix => Icons.blender_rounded,
      PracticeStepVisual.whisk => Icons.cyclone_rounded,
      PracticeStepVisual.blend => Icons.blender_rounded,
      PracticeStepVisual.garnish => Icons.local_cafe_rounded,
    };

    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            right: 20,
            child: _Bubble(color: AppColors.orange.withValues(alpha: 0.3)),
          ),
          Positioned(
            bottom: 14,
            left: 18,
            child: _Bubble(color: AppColors.green.withValues(alpha: 0.25)),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.coral, size: 38),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'BƯỚC $stepNumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
