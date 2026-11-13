import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/learning_course.dart';

class CourseArtwork extends StatelessWidget {
  const CourseArtwork({required this.artwork, this.height = 140, super.key});

  final CourseArtworkType artwork;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = switch (artwork) {
      CourseArtworkType.bartending => (
        background: const Color(0xFFFFE7DD),
        primary: AppColors.coral,
        secondary: const Color(0xFFF2BB78),
        icon: Icons.local_bar_rounded,
      ),
      CourseArtworkType.fruitTea => (
        background: const Color(0xFFE7F0D8),
        primary: const Color(0xFF76A45C),
        secondary: const Color(0xFFF2C76E),
        icon: Icons.emoji_food_beverage_rounded,
      ),
      CourseArtworkType.coffee => (
        background: const Color(0xFFEADFD4),
        primary: const Color(0xFF8F6147),
        secondary: const Color(0xFFC9A889),
        icon: Icons.coffee_rounded,
      ),
    };

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            right: 18,
            child: _Circle(
              color: style.secondary.withValues(alpha: 0.3),
              size: 54,
            ),
          ),
          Positioned(
            bottom: 12,
            left: 20,
            child: _Circle(
              color: style.primary.withValues(alpha: 0.12),
              size: 38,
            ),
          ),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.primary, size: 42),
          ),
          Positioned(
            bottom: 12,
            right: 14,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: style.secondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
