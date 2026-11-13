import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../discover/providers/discover_providers.dart';
import '../../pantry/providers/pantry_providers.dart';
import '../domain/mix_now_matcher.dart';
import '../providers/mix_now_providers.dart';
import '../widgets/mix_recommendation_card.dart';

class MixNowScreen extends ConsumerStatefulWidget {
  const MixNowScreen({super.key});

  @override
  ConsumerState<MixNowScreen> createState() => _MixNowScreenState();
}

class _MixNowScreenState extends ConsumerState<MixNowScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DrinkCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = ref.watch(mixRecommendationsProvider);
    final pantry = ref.watch(pantryIngredientsProvider);

    return SafeArea(
      bottom: false,
      child: recommendations.when(
        loading: () => const FeatureLoadingState(
          message: 'Đang tìm món hợp với căn bếp của bạn...',
        ),
        error: (error, stackTrace) => FeatureErrorState(
          message: 'Chưa thể tải gợi ý đồ uống.',
          onRetry: () => ref.invalidate(recipesProvider),
        ),
        data: (items) {
          final filtered = items.where((recommendation) {
            final recipe = recommendation.recipe;
            final matchesCategory =
                _selectedCategory == null ||
                recipe.category == _selectedCategory;
            final query = MixNowMatcher.normalizeIngredientName(_searchQuery);
            final matchesQuery =
                query.isEmpty ||
                MixNowMatcher.normalizeIngredientName(recipe.name)
                    .contains(query) ||
                MixNowMatcher.normalizeIngredientName(recipe.description)
                    .contains(query);
            return matchesCategory && matchesQuery;
          }).toList();
          final readyCount = items.where((item) => item.canMakeNow).length;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MixNowHeader(
                            pantryCount: pantry.length,
                            readyCount: readyCount,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            key: const ValueKey('mix-search-field'),
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value.trim()),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Tìm đồ uống...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.coral,
                              ),
                              suffixIcon: _searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Xóa tìm kiếm',
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 19),
                          Text(
                            'Loại đồ uống',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _DrinkCategoryFilters(
                            selectedCategory: _selectedCategory,
                            onSelected: (category) =>
                                setState(() => _selectedCategory = category),
                          ),
                          if (pantry.isEmpty) ...[
                            const SizedBox(height: 16),
                            _PantryEmptyHint(
                              onTap: () => context.go('/pantry'),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Gợi ý dành cho bạn',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(
                                '${filtered.length} món',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (filtered.isEmpty)
                            const FeatureEmptyState(
                              title: 'Chưa có gợi ý phù hợp',
                              message: 'Thử từ khóa khác hoặc chọn loại đồ uống khác nhé.',
                            )
                          else
                            for (
                              var index = 0;
                              index < filtered.length;
                              index++
                            ) ...[
                              MixRecommendationCard(
                                recommendation: filtered[index],
                              ),
                              if (index < filtered.length - 1)
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
    );
  }
}

class _MixNowHeader extends StatelessWidget {
  const _MixNowHeader({required this.pantryCount, required this.readyCount});

  final int pantryCount;
  final int readyCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIX NOW',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pha ngon từ những gì bạn có',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 7),
                Text(
                  '$pantryCount nguyên liệu trong Pantry · $readyCount món pha ngay',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.navy, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.blender_rounded, color: AppColors.coral),
          ),
        ],
      ),
    );
  }
}

class _DrinkCategoryFilters extends StatelessWidget {
  const _DrinkCategoryFilters({
    required this.selectedCategory,
    required this.onSelected,
  });

  final DrinkCategory? selectedCategory;
  final ValueChanged<DrinkCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        key: const ValueKey('mix-category-list'),
        scrollDirection: Axis.horizontal,
        children: [
          MixCategoryChip(
            label: 'Tất cả',
            selected: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          for (final category in DrinkCategory.values)
            MixCategoryChip(
              label: category.label,
              selected: selectedCategory == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _PantryEmptyHint extends StatelessWidget {
  const _PantryEmptyHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.kitchen_rounded, color: AppColors.coral),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Thêm nguyên liệu vào Pantry để nhận gợi ý chính xác hơn.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
