import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../providers/discover_providers.dart';
import '../../journal/widgets/favorite_recipe_button.dart';
import '../widgets/drink_artwork.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
                      constraints: const BoxConstraints(maxWidth: 393),
                      child: _RecipeHero(recipe: recipe),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 393),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RecipeFacts(recipe: recipe),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Nguyên liệu',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                Text(
                                  '${recipe.ingredients.length} món cần có',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final tileWidth =
                                    (constraints.maxWidth - 32) / 3;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 4,
                                  children: [
                                    for (final ingredient in recipe.ingredients)
                                      SizedBox(
                                        width: tileWidth,
                                        height: 96,
                                        child: _RecipeIngredientTile(
                                          name: ingredient.name,
                                          amount: ingredient.formattedAmount,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      key: const ValueKey('discover-practice-button'),
                      onPressed: () => context.go('/practice/recipe/$recipeId'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bắt đầu pha'),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vài bước đơn giản. Một ly mát lành.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  const _RecipeHero({required this.recipe});

  final DrinkRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 388,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: ColoredBox(
          color: AppColors.cream,
          child: Stack(
            children: [
              Positioned(
                top: 144,
                left: 76,
                width: 241,
                height: 232,
                child: DrinkArtwork(
                  style: recipe.artwork,
                  backgroundColor: AppColors.cream,
                ),
              ),
              Positioned(
                top: 32,
                left: 24,
                child: IconButton(
                  tooltip: 'Quay lại',
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white,
                    fixedSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Positioned(
                top: 34,
                right: 24,
                child: FavoriteRecipeButton(
                  recipeId: recipe.id,
                  backgroundColor: AppColors.white,
                ),
              ),
              Positioned(
                top: 37,
                left: 80,
                width: 233,
                child: Text(
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                top: 92,
                left: 28,
                right: 28,
                child: Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              if (recipe.category == DrinkCategory.mocktail)
                Positioned(
                  left: 134,
                  bottom: 12,
                  child: Container(
                    width: 125,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF3DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '100% không cồn',
                      style: TextStyle(color: Color(0xFF4B6F20), fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeFacts extends StatelessWidget {
  const _RecipeFacts({required this.recipe});

  final DrinkRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('${recipe.minutes} phút', 'Chuẩn bị'),
      (recipe.difficulty, 'Độ khó'),
      (
        recipe.category == DrinkCategory.mocktail
            ? 'Thanh mát'
            : recipe.category.label,
        'Nhóm',
      ),
      ('${recipe.servings}', 'Khẩu phần'),
    ];

    return Row(
      children: [
        for (final (value, label) in facts)
          Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecipeIngredientTile extends StatelessWidget {
  const _RecipeIngredientTile({required this.name, required this.amount});

  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final normalized = name.toLowerCase();
    final imagePath = normalized.contains('bạc hà')
        ? 'assets/images/figma/ingredient_mint.png'
        : normalized.contains('chanh')
        ? 'assets/images/figma/ingredient_lemon.png'
        : normalized.contains('soda')
        ? 'assets/images/figma/ingredient_soda.png'
        : normalized.contains('đá')
        ? 'assets/images/figma/ingredient_ice.png'
        : normalized.contains('đường')
        ? 'assets/images/figma/ingredient_sugar.png'
        : null;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 48,
            height: 48,
            child: imagePath == null
                ? ColoredBox(
                    color: AppColors.cream,
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: AppColors.green,
                    ),
                  )
                : Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFA94A60),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.navy, fontSize: 12),
        ),
      ],
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
