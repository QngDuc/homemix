import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../discover/providers/discover_providers.dart';
import '../../discover/widgets/recipe_card.dart';
import '../domain/journal_entry.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_entry_card.dart';

enum _JournalSection { entries, favorites }

enum _JournalPeriod {
  anytime('Mọi lúc', null),
  week('7 ngày', 7),
  month('30 ngày', 30),
  quarter('90 ngày', 90);

  const _JournalPeriod(this.label, this.days);

  final String label;
  final int? days;
}

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _JournalSection _section = _JournalSection.entries;
  _JournalPeriod _period = _JournalPeriod.anytime;
  int? _ratingFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);
    final favorites = ref.watch(favoriteRecipeIdsProvider);
    final recipes = ref.watch(recipesProvider);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
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
                      _JournalHeader(),
                      const SizedBox(height: 18),
                      _SectionSelector(
                        selected: _section,
                        entryCount: entries.asData?.value.length,
                        favoriteCount: favorites.asData?.value.length,
                        onChanged: (value) => setState(() {
                          _section = value;
                        }),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        key: const ValueKey('journal-search'),
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _query = value.trim()),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: _section == _JournalSection.entries
                              ? 'Tìm trong nhật ký...'
                              : 'Tìm công thức yêu thích...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.coral,
                          ),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Xóa tìm kiếm',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      if (_section == _JournalSection.entries) ...[
                        const SizedBox(height: 16),
                        _buildFilters(context),
                      ],
                      const SizedBox(height: 18),
                      if (_section == _JournalSection.entries)
                        _buildEntries(context, entries, recipes)
                      else
                        _buildFavorites(context, favorites, recipes),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thời gian', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        SizedBox(
          height: 40,
          child: ListView(
            key: const ValueKey('journal-period-filters'),
            scrollDirection: Axis.horizontal,
            children: [
              for (final period in _JournalPeriod.values)
                _FilterChip(
                  key: ValueKey('journal-period-${period.name}'),
                  label: period.label,
                  selected: period == _period,
                  onTap: () => setState(() => _period = period),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('Đánh giá', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        SizedBox(
          height: 40,
          child: ListView(
            key: const ValueKey('journal-rating-filters'),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                key: const ValueKey('journal-rating-any'),
                label: 'Tất cả',
                selected: _ratingFilter == null,
                onTap: () => setState(() => _ratingFilter = null),
              ),
              for (var rating = 5; rating >= 1; rating--)
                _FilterChip(
                  key: ValueKey('journal-rating-$rating'),
                  label: '$rating sao',
                  selected: _ratingFilter == rating,
                  onTap: () => setState(() => _ratingFilter = rating),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntries(
    BuildContext context,
    AsyncValue<List<JournalEntry>> entries,
    AsyncValue<List<DrinkRecipe>> recipes,
  ) {
    return entries.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: FeatureLoadingState(message: 'Đang mở nhật ký...'),
      ),
      error: (error, stackTrace) => FeatureErrorState(
        message: 'Chưa thể đọc nhật ký đã lưu.',
        onRetry: () => ref.invalidate(journalEntriesProvider),
      ),
      data: (allEntries) {
        final filtered = _filterEntries(allEntries);
        if (allEntries.isEmpty) {
          return const FeatureEmptyState(
            title: 'Nhật ký của bạn đang trống',
            message: 'Hoàn thành một buổi Practice rồi lưu kết quả để ghi lại hành trình pha chế.',
          );
        }
        if (filtered.isEmpty) {
          return const FeatureEmptyState(
            title: 'Không tìm thấy mục phù hợp',
            message:
                'Thử từ khóa khác hoặc thay đổi bộ lọc thời gian, đánh giá.',
          );
        }

        final availableRecipes = recipes.asData?.value ?? const <DrinkRecipe>[];
        return Column(
          children: [
            for (var index = 0; index < filtered.length; index++) ...[
              JournalEntryCard(
                entry: filtered[index],
                recipe: _findRecipe(availableRecipes, filtered[index].recipeId),
              ),
              if (index < filtered.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  List<JournalEntry> _filterEntries(List<JournalEntry> entries) {
    final query = _query.toLowerCase();
    final cutoff = _period.days == null
        ? null
        : DateTime.now().subtract(Duration(days: _period.days!));
    final filtered = entries.where((entry) {
      final matchesSearch =
          query.isEmpty || entry.recipeName.toLowerCase().contains(query);
      final matchesPeriod = cutoff == null || !entry.date.isBefore(cutoff);
      final matchesRating =
          _ratingFilter == null || entry.rating == _ratingFilter;
      return matchesSearch && matchesPeriod && matchesRating;
    }).toList()..sort((first, second) => second.date.compareTo(first.date));
    return filtered;
  }

  Widget _buildFavorites(
    BuildContext context,
    AsyncValue<Set<String>> favorites,
    AsyncValue<List<DrinkRecipe>> recipes,
  ) {
    return favorites.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: FeatureLoadingState(message: 'Đang tải công thức yêu thích...'),
      ),
      error: (error, stackTrace) => FeatureErrorState(
        message: 'Chưa thể đọc danh sách yêu thích.',
        onRetry: () => ref.invalidate(favoriteRecipeIdsProvider),
      ),
      data: (ids) => recipes.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: FeatureLoadingState(message: 'Đang tải công thức...'),
        ),
        error: (error, stackTrace) => FeatureErrorState(
          message: 'Chưa thể tải công thức yêu thích.',
          onRetry: () => ref.invalidate(recipesProvider),
        ),
        data: (allRecipes) {
          final filtered = allRecipes
              .where(
                (recipe) =>
                    ids.contains(recipe.id) &&
                    (_query.isEmpty ||
                        recipe.name.toLowerCase().contains(
                          _query.toLowerCase(),
                        )),
              )
              .toList();
          if (ids.isEmpty) {
            return const FeatureEmptyState(
              title: 'Chưa có công thức yêu thích',
              message: 'Chạm biểu tượng trái tim ở Discover để lưu món bạn muốn pha sau.',
            );
          }
          if (filtered.isEmpty) {
            return const FeatureEmptyState(
              title: 'Không tìm thấy công thức',
              message: 'Thử một từ khóa khác nhé.',
            );
          }
          return Column(
            children: [
              for (var index = 0; index < filtered.length; index++) ...[
                SizedBox(
                  height: 245,
                  child: RecipeCard(recipe: filtered[index]),
                ),
                if (index < filtered.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JOURNAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Hành trình pha chế của bạn',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 5),
              Text(
                'Lưu lại những ly ngon và điều bạn muốn thử lần sau.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.pastelPink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_stories_rounded, color: AppColors.coral),
        ),
      ],
    );
  }
}

class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.selected,
    required this.entryCount,
    required this.favoriteCount,
    required this.onChanged,
  });

  final _JournalSection selected;
  final int? entryCount;
  final int? favoriteCount;
  final ValueChanged<_JournalSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_JournalSection>(
      key: const ValueKey('journal-section-selector'),
      segments: [
        ButtonSegment(
          value: _JournalSection.entries,
          icon: const Icon(Icons.menu_book_rounded),
          label: Text('Nhật ký${entryCount == null ? '' : ' ($entryCount)'}'),
        ),
        ButtonSegment(
          value: _JournalSection.favorites,
          icon: const Icon(Icons.favorite_border_rounded),
          label: Text(
            'Yêu thích${favoriteCount == null ? '' : ' ($favoriteCount)'}',
          ),
        ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      padding: const EdgeInsets.only(right: 7),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 9),
      ),
    );
  }
}

DrinkRecipe? _findRecipe(List<DrinkRecipe> recipes, String recipeId) {
  for (final recipe in recipes) {
    if (recipe.id == recipeId) {
      return recipe;
    }
  }
  return null;
}
