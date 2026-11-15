import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
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
  String _selectedAvailability = 'Tất cả';
  bool _showSearch = false;

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
            final matchesAvailability = switch (_selectedAvailability) {
              'Pha được ngay' => recommendation.canMakeNow,
              'Thiếu nguyên liệu' => !recommendation.canMakeNow,
              _ => true,
            };
            final query = MixNowMatcher.normalizeIngredientName(_searchQuery);
            final matchesQuery =
                query.isEmpty ||
                MixNowMatcher.normalizeIngredientName(
                  recommendation.recipe.name,
                ).contains(query) ||
                MixNowMatcher.normalizeIngredientName(
                  recommendation.recipe.description,
                ).contains(query);
            return matchesAvailability && matchesQuery;
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
                            onSearchPressed: () =>
                                setState(() => _showSearch = !_showSearch),
                          ),
                          const SizedBox(height: 24),
                          const _PossibilitiesBanner(),
                          if (_showSearch) ...[
                            const SizedBox(height: 12),
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
                                suffixIcon: IconButton(
                                  tooltip: 'Xóa tìm kiếm',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _AvailabilityFilters(
                            selectedFilter: _selectedAvailability,
                            onSelected: (filter) =>
                                setState(() => _selectedAvailability = filter),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Gợi ý từ tủ nguyên liệu',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(
                                '${filtered.length} gợi ý',
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
  const _MixNowHeader({
    required this.pantryCount,
    required this.readyCount,
    required this.onSearchPressed,
  });

  final int pantryCount;
  final int readyCount;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pha ngay',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 23, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              key: const ValueKey('mix-search-toggle'),
              tooltip: 'Tìm đồ uống',
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search_rounded),
            ),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'home',
                    style: TextStyle(color: AppColors.navy),
                  ),
                  TextSpan(
                    text: 'mix',
                    style: TextStyle(color: AppColors.coral),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Hôm nay bạn\npha được gì?',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 26, height: 1.35),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4E3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Có sẵn $pantryCount nguyên liệu · $readyCount pha ngay',
            style: const TextStyle(
              color: Color(0xFF4B6F20),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityFilters extends StatelessWidget {
  const _AvailabilityFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        key: const ValueKey('mix-availability-filter-list'),
        scrollDirection: Axis.horizontal,
        children: [
          for (final label in const [
            'Tất cả',
            'Pha được ngay',
            'Thiếu nguyên liệu',
          ])
            MixCategoryChip(
              label: label,
              selected: selectedFilter == label,
              onTap: () => onSelected(label),
            ),
        ],
      ),
    );
  }
}

class _PossibilitiesBanner extends StatelessWidget {
  const _PossibilitiesBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyên liệu sẵn có,\nvô vàn cách pha!',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Ít mua sắm, thêm niềm vui.',
                  style: TextStyle(color: Color(0xFFAA4C62), fontSize: 11),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/onboarding_cocktail.png',
            width: 76,
            height: 76,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
