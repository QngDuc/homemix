import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../../features/discover/widgets/drink_artwork.dart';
import '../domain/practice_recipe.dart';

class PracticeRecipeCard extends StatelessWidget {
  const PracticeRecipeCard({required this.practiceRecipe, super.key});

  final PracticeRecipe practiceRecipe;

  @override
  Widget build(BuildContext context) {
    final recipe = practiceRecipe.recipe;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: ValueKey('practice-recipe-${recipe.id}'),
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/practice/recipe/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: DrinkArtwork(style: recipe.artwork),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        _CardInfo(
                          icon: Icons.schedule_rounded,
                          label: '${recipe.minutes} phút',
                        ),
                        _CardInfo(
                          icon: Icons.list_alt_rounded,
                          label: '${practiceRecipe.steps.length} bước',
                        ),
                        _CardInfo(
                          icon: recipe.category == DrinkCategory.smoothie
                              ? Icons.blender_rounded
                              : Icons.local_cafe_rounded,
                          label: recipe.difficulty,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.coral),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
