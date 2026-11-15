import 'package:flutter/material.dart';

import '../domain/learning_course.dart';

class CourseArtwork extends StatelessWidget {
  const CourseArtwork({required this.artwork, this.height = 140, super.key});

  final CourseArtworkType artwork;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imagePath = switch (artwork) {
      CourseArtworkType.bartending => 'assets/images/figma/discover_mojito.png',
      CourseArtworkType.fruitTea =>
        'assets/images/figma/learning_fruit_tea.png',
      CourseArtworkType.coffee => 'assets/images/figma/discover_coffee.png',
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
