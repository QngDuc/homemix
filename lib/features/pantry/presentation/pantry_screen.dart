import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../domain/pantry_ingredient.dart';
import '../providers/pantry_providers.dart';
import '../widgets/pantry_ingredient_card.dart';
import '../widgets/pantry_ingredient_form.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  PantryCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(pantryIngredientsProvider);
    final filteredIngredients = ingredients.where((ingredient) {
      final matchesCategory =
          _selectedCategory == null || ingredient.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          ingredient.name.toLowerCase().contains(query) ||
          ingredient.category.label.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    final expiringCount = ingredients
        .where(
          (ingredient) =>
              ingredient.expiryStatus == PantryExpiryStatus.expiringSoon,
        )
        .length;
    final expiredCount = ingredients
        .where(
          (ingredient) => ingredient.expiryStatus == PantryExpiryStatus.expired,
        )
        .length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('pantry-add-button'),
        onPressed: _addIngredient,
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm nguyên liệu'),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const ValueKey('pantry-list'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PantryHeader(
                          ingredientCount: ingredients.length,
                          expiringCount: expiringCount,
                          expiredCount: expiredCount,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          key: const ValueKey('pantry-search-field'),
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value.trim()),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Tìm nguyên liệu...',
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
                          'Danh mục',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _CategoryFilters(
                          selectedCategory: _selectedCategory,
                          onSelected: (category) =>
                              setState(() => _selectedCategory = category),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCategory == null
                                    ? 'Nguyên liệu của bạn'
                                    : _selectedCategory!.label,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Text(
                              '${filteredIngredients.length} món',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (filteredIngredients.isEmpty)
                          FeatureEmptyState(
                            title: ingredients.isEmpty
                                ? 'Pantry đang trống'
                                : 'Không tìm thấy nguyên liệu',
                            message: ingredients.isEmpty
                                ? 'Thêm nguyên liệu đầu tiên để bắt đầu nhé.'
                                : 'Thử từ khóa khác hoặc chọn danh mục khác.',
                          )
                        else
                          for (
                            var index = 0;
                            index < filteredIngredients.length;
                            index++
                          ) ...[
                            PantryIngredientCard(
                              ingredient: filteredIngredients[index],
                              onEdit: () =>
                                  _editIngredient(filteredIngredients[index]),
                              onDelete: () =>
                                  _confirmDelete(filteredIngredients[index]),
                            ),
                            if (index < filteredIngredients.length - 1)
                              const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addIngredient() async {
    final ingredient = await _showIngredientForm();
    if (ingredient == null || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).add(ingredient);
    _showMessage('Đã thêm ${ingredient.name} vào Pantry.');
  }

  Future<void> _editIngredient(PantryIngredient ingredient) async {
    final updated = await _showIngredientForm(ingredient: ingredient);
    if (updated == null || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).update(updated);
    _showMessage('Đã cập nhật ${updated.name}.');
  }

  Future<PantryIngredient?> _showIngredientForm({
    PantryIngredient? ingredient,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return showModalBottomSheet<PantryIngredient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => PantryIngredientForm(ingredient: ingredient),
    );
  }

  Future<void> _confirmDelete(PantryIngredient ingredient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nguyên liệu?'),
        content: Text('Bạn có chắc muốn xóa ${ingredient.name} khỏi Pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).delete(ingredient.id);
    _showMessage('Đã xóa ${ingredient.name}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PantryHeader extends StatelessWidget {
  const _PantryHeader({
    required this.ingredientCount,
    required this.expiringCount,
    required this.expiredCount,
  });

  final int ingredientCount;
  final int expiringCount;
  final int expiredCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GÓC BẾP CỦA BẠN',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.coral,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pantry',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.pastelPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.kitchen_rounded, color: AppColors.coral),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$ingredientCount nguyên liệu đang có trong bếp',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (expiringCount > 0 || expiredCount > 0) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (expiringCount > 0)
                _SummaryBadge(
                  icon: Icons.schedule_rounded,
                  label: '$expiringCount sắp hết hạn',
                  color: const Color(0xFFFFF0D8),
                  foreground: const Color(0xFFB36B25),
                ),
              if (expiredCount > 0)
                _SummaryBadge(
                  icon: Icons.error_outline_rounded,
                  label: '$expiredCount đã hết hạn',
                  color: const Color(0xFFFBE4E6),
                  foreground: const Color(0xFFC65363),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedCategory,
    required this.onSelected,
  });

  final PantryCategory? selectedCategory;
  final ValueChanged<PantryCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        key: const ValueKey('pantry-category-list'),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Tất cả',
            selected: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          for (final category in PantryCategory.values)
            _FilterChip(
              label: category.label,
              selected: selectedCategory == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        key: ValueKey('pantry-category-$label'),
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
