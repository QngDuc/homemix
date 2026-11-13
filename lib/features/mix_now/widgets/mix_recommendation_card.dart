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
        ? const Color(0xFFEAF2DA)
        : recommendation.matchPercentage >= 50
        ? const Color(0xFFFFF0D8)
        : const Color(0xFFFBE4E6);

    return Material(
      key: ValueKey('mix-recommendation-${recipe.id}'),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/mix-now/recipe/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 82,
                height: 100,
                child: DrinkArtwork(style: recipe.artwork),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.category.label}  ·  ${recipe.minutes} phút  ·  ${recipe.difficulty}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${recommendation.matchPercentage}% nguyên liệu có sẵn',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${recommendation.availableIngredientCount}/${recommendation.ingredients.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: recommendation.matchPercentage / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        recommendation.canMakeNow
                            ? 'Có thể pha ngay'
                            : recommendation.status ==
                                  RecipeMatchStatus.notEnough
                            ? 'Chưa đủ nguyên liệu'
                            : 'Thiếu ${recommendation.missingIngredientCount} nguyên liệu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
