import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../features/discover/widgets/drink_artwork.dart';
import '../domain/mix_recommendation.dart';

class MixRecommendationCard extends StatelessWidget {
  const MixRecommendationCard({required this.recommendation, super.key});

  final MixRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    final statusColor = recommendation.canMakeNow
        ? const Color(0xFF638B2F)
        : recommendation.matchPercentage >= 50
        ? const Color(0xFFB36B25)
        : const Color(0xFFC65363);
    final statusBackground = recommendation.canMakeNow
        ? const Color(0xFFEEF4E3)
        : recommendation.matchPercentage >= 50
        ? const Color(0xFFFFF0D8)
        : const Color(0xFFFFEED7);
    final drinkImage = switch (recipe.id) {
      'peach-lemongrass-tea' => 'assets/images/figma/mix_honey_citrus.png',
      'strawberry-yogurt' => 'assets/images/figma/mix_strawberry_tea.png',
      _ => null,
    };

    return Material(
      key: ValueKey('mix-recommendation-${recipe.id}'),
      color: recommendation.canMakeNow
          ? AppColors.cream
          : const Color(0xFFF9E1E5),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/mix-now/recipe/${recipe.id}'),
        child: SizedBox(
          height: recommendation.canMakeNow ? 140 : 184,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 88,
                    height: recommendation.canMakeNow ? 116 : 126,
                    child: drinkImage == null
                        ? DrinkArtwork(style: recipe.artwork)
                        : Image.asset(drinkImage, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          recommendation.canMakeNow
                              ? 'Sẵn sàng pha'
                              : 'Thiếu nguyên liệu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${recommendation.availableIngredientCount}/'
                        '${recommendation.ingredients.length} nguyên liệu · '
                        '${recommendation.matchPercentage}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: recommendation.matchPercentage / 100,
                          minHeight: 4,
                          backgroundColor: const Color(0xFFE3D6D5),
                          color: statusColor,
                        ),
                      ),
                      if (!recommendation.canMakeNow) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Thiếu: ${recommendation.ingredients.where((item) => !item.isAvailable).map((item) => item.recipeIngredient.name).join(', ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              recommendation.canMakeNow
                                  ? 'Bắt đầu pha'
                                  : 'Xem công thức',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MixCategoryChip extends StatelessWidget {
  const MixCategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        key: ValueKey('mix-category-$label'),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: AppColors.navy,
        backgroundColor: AppColors.white,
        side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}
