import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../discover/widgets/drink_artwork.dart';
import '../domain/mix_recommendation.dart';
import '../providers/mix_now_providers.dart';

class MixRecipeDetailScreen extends ConsumerWidget {
  const MixRecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(mixRecipeByIdProvider(recipeId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: recommendation.when(
          loading: () =>
              const FeatureLoadingState(message: 'Đang tính nguyên liệu...'),
          error: (error, stackTrace) => FeatureErrorState(
            message: 'Chưa thể mở gợi ý này.',
            onRetry: () => ref.invalidate(mixRecommendationsProvider),
          ),
          data: (match) {
            if (match == null) {
              return const FeatureEmptyState(
                title: 'Không tìm thấy đồ uống',
                message: 'Gợi ý này có thể đã được cập nhật.',
              );
            }
            return _RecipeMatchDetails(recommendation: match);
          },
        ),
      ),
    );
  }
}

class _RecipeMatchDetails extends StatelessWidget {
  const _RecipeMatchDetails({required this.recommendation});

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
                    IconButton(
                      key: const ValueKey('mix-detail-back-button'),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: DrinkArtwork(style: recipe.artwork),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                recommendation.canMakeNow
                                    ? Icons.check_circle_rounded
                                    : Icons.info_outline_rounded,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation.status.label,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${recommendation.matchPercentage}%',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: recommendation.matchPercentage / 100,
                              minHeight: 7,
                              backgroundColor: AppColors.white,
                              color: statusColor,
                            ),
                          ),
                          if (recommendation.missingIngredients.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Còn thiếu: ${recommendation.missingIngredients.map((item) => item.recipeIngredient.name).join(', ')}',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nguyên liệu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 11),
                    _IngredientList(recommendation: recommendation),
                    const SizedBox(height: 25),
                    Text(
                      'Cách pha',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 11),
                    for (
                      var index = 0;
                      index < recipe.steps.length;
                      index++
                    ) ...[
                      _StepCard(
                        number: index + 1,
                        description: recipe.steps[index],
                      ),
                      const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('mix-practice-button'),
                        onPressed: () =>
                            context.go('/practice/recipe/${recipe.id}'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Thực hành công thức'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.recommendation});

  final MixRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (
            var index = 0;
            index < recommendation.ingredients.length;
            index++
          ) ...[
            if (index > 0) const Divider(height: 18),
            _IngredientRow(match: recommendation.ingredients[index]),
          ],
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.match});

  final MatchedRecipeIngredient match;

  @override
  Widget build(BuildContext context) {
    final color = match.isAvailable ? AppColors.green : const Color(0xFFC65363);
    final status = switch ((match.isAvailable, match.isSubstitution)) {
      (true, true) => 'Thay bằng ${match.pantryIngredient!.name}',
      (true, false) => 'Có sẵn',
      (false, _) => 'Cần bổ sung',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          match.isAvailable
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.recipeIngredient.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (match.isSubstitution || !match.isAvailable) ...[
                const SizedBox(height: 3),
                Text(
                  status,
                  style: TextStyle(
                    color: match.isAvailable
                        ? const Color(0xFF638B2F)
                        : const Color(0xFFC65363),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          match.recipeIngredient.formattedAmount,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.coral),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.description});

  final int number;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
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
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
