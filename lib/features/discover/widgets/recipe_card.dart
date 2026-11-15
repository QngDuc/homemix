import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../journal/widgets/favorite_recipe_button.dart';
import 'drink_artwork.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({required this.recipe, super.key});

  final DrinkRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final surface = recipe.artwork == DrinkArtworkStyle.strawberryYogurt
        ? const Color(0xFFF9E1E5)
        : AppColors.cream;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/discover/recipe/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 124,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DrinkArtwork(style: recipe.artwork),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: FavoriteRecipeButton(
                        recipeId: recipe.id,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recipe.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.minutes} phút',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4E3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.difficulty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B6F20),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeCategoryBadge extends StatelessWidget {
  const RecipeCategoryBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
