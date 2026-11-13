import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class FeatureLoadingState extends StatelessWidget {
  const FeatureLoadingState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.coral),
          const SizedBox(height: 14),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class FeatureEmptyState extends StatelessWidget {
  const FeatureEmptyState({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.search_off_rounded,
      title: title,
      message: message,
    );
  }
}

class FeatureErrorState extends StatelessWidget {
  const FeatureErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.cloud_off_rounded,
      title: 'Có chút trục trặc',
      message: message,
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Thử lại'),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.coral, size: 34),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 8), action!],
        ],
      ),
    );
  }
}
