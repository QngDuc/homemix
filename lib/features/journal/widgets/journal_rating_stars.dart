import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class JournalRatingStars extends StatelessWidget {
  const JournalRatingStars({
    required this.rating,
    this.size = 17,
    this.showUnrated = true,
    super.key,
  });

  final int? rating;
  final double size;
  final bool showUnrated;

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return showUnrated
          ? Text('Chưa đánh giá', style: Theme.of(context).textTheme.bodySmall)
          : const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var value = 1; value <= 5; value++)
          Icon(
            value <= rating! ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.orange,
            size: size,
          ),
      ],
    );
  }
}
