import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../providers/discover_providers.dart';
import '../../journal/widgets/favorite_recipe_button.dart';
import '../widgets/drink_artwork.dart';
import '../widgets/recipe_card.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: recipes.when(
          loading: () =>
              const FeatureLoadingState(message: 'Đang mở công thức...'),
          error: (error, stackTrace) => FeatureErrorState(
            message: 'Chưa thể mở công thức này.',
            onRetry: () => ref.invalidate(recipesProvider),
          ),
          data: (items) {
            final recipe = items
                .where((item) => item.id == recipeId)
                .firstOrNull;
            if (recipe == null) {
              return const FeatureEmptyState(
                title: 'Không tìm thấy công thức',
                message: 'Công thức này có thể đã được cập nhật.',
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                  ),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                                const Spacer(),
                                FavoriteRecipeButton(
                                  recipeId: recipe.id,
                                  backgroundColor: AppColors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 230,
                              width: double.infinity,
                              child: DrinkArtwork(style: recipe.artwork),
                            ),
                            const SizedBox(height: 20),
                            RecipeCategoryBadge(label: recipe.category.label),
                            const SizedBox(height: 10),
                            Text(
                              recipe.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe.description,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.muted,
                                    height: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 17),
                            Wrap(
                              spacing: 9,
                              runSpacing: 9,
                              children: [
                                _InfoPill(
                                  icon: Icons.schedule_rounded,
                                  label: '${recipe.minutes} phút',
                                ),
                                _InfoPill(
                                  icon: Icons.signal_cellular_alt_rounded,
                                  label: recipe.difficulty,
                                ),
                                _InfoPill(
                                  icon: Icons.local_drink_outlined,
                                  label: '${recipe.servings} khẩu phần',
                                ),
                              ],
                            ),
                            const SizedBox(height: 27),
                            Text(
                              'Nguyên liệu',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            _DetailCard(
                              child: Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < recipe.ingredients.length;
                                    index++
                                  ) ...[
                                    if (index > 0) const Divider(height: 20),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.green,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            recipe.ingredients[index].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ),
                                        Text(
                                          recipe
                                              .ingredients[index]
                                              .formattedAmount,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.navy,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              'Cách pha',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            for (
                              var index = 0;
                              index < recipe.steps.length;
                              index++
                            ) ...[
                              _StepTile(
                                number: index + 1,
                                description: recipe.steps[index],
                              ),
                              const SizedBox(height: 10),
                            ],
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                key: const ValueKey('discover-practice-button'),
                                onPressed: () =>
                                    context.go('/practice/recipe/${recipe.id}'),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Bắt đầu pha'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.coral,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.coral),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.description});

  final int number;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.pastelPink,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
