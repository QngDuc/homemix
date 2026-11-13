import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';

class FeaturePreviewScreen extends StatelessWidget {
  const FeaturePreviewScreen({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.pastelPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.coral, size: 38),
                ),
                const SizedBox(height: 20),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 22),
                const FeatureEmptyState(
                  title: 'Sắp có mặt',
                  message:
                      'Tính năng này sẽ được hoàn thiện ở giai đoạn tiếp theo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
