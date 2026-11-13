import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class LearningProgressBar extends StatelessWidget {
  const LearningProgressBar({
    required this.progress,
    required this.label,
    this.color = AppColors.coral,
    super.key,
  });

  final double progress;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: color,
            backgroundColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}
