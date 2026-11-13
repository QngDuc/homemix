import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../discover/widgets/drink_artwork.dart';

class JournalArtwork extends StatelessWidget {
  const JournalArtwork({
    this.recipe,
    this.imagePath,
    this.height = 120,
    super.key,
  });

  final DrinkRecipe? recipe;
  final String? imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null && recipe != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: DrinkArtwork(style: recipe!.artwork),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            imagePath == null
                ? Icons.local_cafe_rounded
                : Icons.add_photo_alternate_outlined,
            size: 36,
            color: AppColors.coral,
          ),
          if (imagePath != null) ...[
            const SizedBox(height: 6),
            Text(
              'Ảnh cá nhân chưa được hỗ trợ',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
