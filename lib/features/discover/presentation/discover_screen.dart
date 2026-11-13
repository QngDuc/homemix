import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../../core/widgets/feature_state.dart';
import '../providers/discover_providers.dart';
import '../widgets/drink_artwork.dart';
import '../widgets/recipe_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  DrinkCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeHeader(),
                const SizedBox(height: 22),
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Tìm một món thật ngon...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.coral,
                    ),
                    suffixIcon: Icon(
                      Icons.tune_rounded,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                recipes.when(
                  data: (items) => _buildCatalog(context, items),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 72),
                    child: FeatureLoadingState(
                      message: 'Đang chuẩn bị công thức...',
                    ),
                  ),
                  error: (error, stackTrace) => FeatureErrorState(
                    message: 'Chưa thể tải danh sách công thức.',
                    onRetry: () => ref.invalidate(recipesProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, List<DrinkRecipe> recipes) {
    final featured = recipes.where((recipe) => recipe.isFeatured).firstOrNull;
    final filtered = recipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == null || recipe.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query) ||
          recipe.category.label.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchQuery.isEmpty &&
            _selectedCategory == null &&
            featured != null) ...[
          _SectionHeading(
            eyebrow: 'MÓN ĐƯỢC YÊU THÍCH',
            title: 'Hôm nay pha gì?',
            trailing: 'Gợi ý cho bạn',
          ),
          const SizedBox(height: 14),
          _FeaturedRecipeCard(recipe: featured),
          const SizedBox(height: 27),
        ],
        const _SectionHeading(eyebrow: 'KHÁM PHÁ', title: 'Chọn theo sở thích'),
        const SizedBox(height: 13),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CategoryChip(
                label: 'Tất cả',
                selected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              for (final category in DrinkCategory.values)
                _CategoryChip(
                  label: category.label,
                  selected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
            ],
          ),
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Expanded(
              child: Text(
                _searchQuery.isEmpty
                    ? 'Công thức dành cho bạn'
                    : 'Kết quả tìm kiếm',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              '${filtered.length} món',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 13),
        if (filtered.isEmpty)
          const FeatureEmptyState(
            title: 'Chưa tìm thấy món phù hợp',
            message: 'Thử từ khóa khác hoặc chọn một danh mục nhé.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              if (columns == 1) {
                return Column(
                  children: [
                    for (final recipe in filtered) ...[
                      SizedBox(height: 245, child: RecipeCard(recipe: recipe)),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 270,
                ),
                itemBuilder: (context, index) =>
                    RecipeCard(recipe: filtered[index]),
              );
            },
          ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOMEmix',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 4),
              Text('Chào bạn,', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                'cùng pha điều hay!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.pastelPink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_cafe_rounded, color: AppColors.coral),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.coral,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard({required this.recipe});

  final DrinkRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pastelPink,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/discover/recipe/${recipe.id}'),
        child: SizedBox(
          height: 204,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artworkWidth = constraints.maxWidth * 0.44;
              return Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 8,
                    bottom: 16,
                    width: artworkWidth,
                    child: DrinkArtwork(
                      style: recipe.artwork,
                      backgroundColor: AppColors.pastelPink,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, artworkWidth + 6, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RecipeCategoryBadge(label: 'GỢI Ý HÔM NAY'),
                        const Spacer(),
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 19),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${recipe.minutes} phút  ·  ${recipe.difficulty}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.navy),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Xem công thức',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppColors.navy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
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
