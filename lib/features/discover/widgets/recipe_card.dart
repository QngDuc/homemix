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
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/discover/recipe/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DrinkArtwork(style: recipe.artwork),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _CategoryBadge(label: recipe.category.label),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: FavoriteRecipeButton(recipeId: recipe.id),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recipe.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.minutes} phút',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.signal_cellular_alt_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe.difficulty,
                    style: Theme.of(context).textTheme.bodyMedium,
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
  Widget build(BuildContext context) => _CategoryBadge(label: label);
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

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
